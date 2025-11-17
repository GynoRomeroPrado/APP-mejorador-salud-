import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException, ConflictException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { SupabaseService } from '../common/supabase/supabase.service';

describe('AuthService', () => {
  let service: AuthService;
  let supabaseService: jest.Mocked<SupabaseService>;
  let jwtService: jest.Mocked<JwtService>;
  let configService: jest.Mocked<ConfigService>;

  const mockSupabaseResponse = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: SupabaseService,
          useValue: mockSupabaseResponse,
        },
        {
          provide: JwtService,
          useValue: {
            signAsync: jest.fn(),
            verify: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string) => {
              const config = {
                JWT_SECRET: 'test-secret',
                JWT_EXPIRATION: '15m',
                JWT_REFRESH_SECRET: 'test-refresh-secret',
                JWT_REFRESH_EXPIRATION: '7d',
              };
              return config[key];
            }),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    supabaseService = module.get(SupabaseService);
    jwtService = module.get(JwtService);
    configService = module.get(ConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    const registerDto = {
      email: 'test@example.com',
      password: 'password123',
      fullName: 'Test User',
    };

    it('should successfully register a new user', async () => {
      const hashedPassword = 'hashedPassword123';
      const newUser = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
      };

      jest.spyOn(bcrypt, 'hash').mockImplementation(() => Promise.resolve(hashedPassword as never));

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: null, error: null }) // Email check
        .mockResolvedValueOnce({ data: newUser, error: null }); // User creation

      mockSupabaseResponse.insert.mockResolvedValue({ data: null, error: null });

      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      const result = await service.register(registerDto);

      expect(result).toEqual({
        user: {
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
        },
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      });

      expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
    });

    it('should throw ConflictException if email already exists', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: { user_id: 'existing' },
        error: null,
      });

      await expect(service.register(registerDto)).rejects.toThrow(
        ConflictException,
      );
    });

    it('should throw error if user creation fails', async () => {
      const hashedPassword = 'hashedPassword123';
      jest.spyOn(bcrypt, 'hash').mockImplementation(() => Promise.resolve(hashedPassword as never));

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: null, error: null }) // Email check
        .mockResolvedValueOnce({
          data: null,
          error: { message: 'Database error' },
        }); // User creation fails

      await expect(service.register(registerDto)).rejects.toThrow(
        'Failed to create user: Database error',
      );
    });

    it('should create user settings and stats on registration', async () => {
      const hashedPassword = 'hashedPassword123';
      const newUser = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
      };

      jest.spyOn(bcrypt, 'hash').mockImplementation(() => Promise.resolve(hashedPassword as never));

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: null, error: null })
        .mockResolvedValueOnce({ data: newUser, error: null });

      const insertSpy = jest.spyOn(mockSupabaseResponse, 'insert');
      mockSupabaseResponse.insert.mockResolvedValue({ data: null, error: null });

      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      await service.register(registerDto);

      expect(insertSpy).toHaveBeenCalled();
    });
  });

  describe('login', () => {
    const loginDto = {
      email: 'test@example.com',
      password: 'password123',
    };

    it('should successfully login user with valid credentials', async () => {
      const user = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
        password_hash: 'hashedPassword',
        subscription_tier: 'free',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: user,
        error: null,
      });

      jest.spyOn(bcrypt, 'compare').mockImplementation(() => Promise.resolve(true as never));

      mockSupabaseResponse.update.mockResolvedValue({ data: null, error: null });

      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      const result = await service.login(loginDto);

      expect(result).toEqual({
        user: {
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
          subscriptionTier: 'free',
        },
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      });
    });

    it('should throw UnauthorizedException if user not found', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: null,
      });

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException if password is invalid', async () => {
      const user = {
        user_id: 'u_123',
        email: 'test@example.com',
        password_hash: 'hashedPassword',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: user,
        error: null,
      });

      jest.spyOn(bcrypt, 'compare').mockImplementation(() => Promise.resolve(false as never));

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should update last_active_at on successful login', async () => {
      const user = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
        password_hash: 'hashedPassword',
        subscription_tier: 'free',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: user,
        error: null,
      });

      jest.spyOn(bcrypt, 'compare').mockImplementation(() => Promise.resolve(true as never));

      const updateSpy = jest.spyOn(mockSupabaseResponse, 'update');
      mockSupabaseResponse.update.mockResolvedValue({ data: null, error: null });

      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      await service.login(loginDto);

      expect(updateSpy).toHaveBeenCalled();
    });
  });

  describe('googleLogin', () => {
    const googleUser = {
      id: 'google_123',
      email: 'google@example.com',
      firstName: 'Google',
      lastName: 'User',
      picture: 'https://example.com/picture.jpg',
    };

    it('should login existing Google user', async () => {
      const existingUser = {
        user_id: 'u_123',
        email: 'google@example.com',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: existingUser,
        error: null,
      });

      mockSupabaseResponse.update.mockResolvedValue({ data: null, error: null });

      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      const result = await service.googleLogin(googleUser);

      expect(result.user.userId).toBe('u_123');
      expect(result.user.email).toBe('google@example.com');
    });

    it('should create new user for first-time Google login', async () => {
      const newUser = {
        user_id: 'u_new',
        email: 'google@example.com',
      };

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: null, error: null }) // User doesn't exist
        .mockResolvedValueOnce({ data: newUser, error: null }); // New user created

      mockSupabaseResponse.insert.mockResolvedValue({ data: null, error: null });

      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      const result = await service.googleLogin(googleUser);

      expect(result.user.userId).toBe('u_new');
      expect(result.user.fullName).toBe('Google User');
    });

    it('should create OAuth connection for new Google user', async () => {
      const newUser = {
        user_id: 'u_new',
        email: 'google@example.com',
      };

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: null, error: null })
        .mockResolvedValueOnce({ data: newUser, error: null });

      const insertSpy = jest.spyOn(mockSupabaseResponse, 'insert');
      mockSupabaseResponse.insert.mockResolvedValue({ data: null, error: null });

      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      await service.googleLogin(googleUser);

      expect(insertSpy).toHaveBeenCalled();
    });
  });

  describe('refreshToken', () => {
    it('should generate new tokens with valid refresh token', async () => {
      const payload = {
        sub: 'u_123',
        email: 'test@example.com',
      };

      jest.spyOn(jwtService, 'verify').mockReturnValue(payload);
      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('new-access-token')
        .mockResolvedValueOnce('new-refresh-token');

      const result = await service.refreshToken('valid-refresh-token');

      expect(result).toEqual({
        accessToken: 'new-access-token',
        refreshToken: 'new-refresh-token',
      });
    });

    it('should throw UnauthorizedException with invalid refresh token', async () => {
      jest.spyOn(jwtService, 'verify').mockImplementation(() => {
        throw new Error('Invalid token');
      });

      await expect(
        service.refreshToken('invalid-refresh-token'),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('validateUser', () => {
    it('should return user by userId', async () => {
      const user = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: user,
        error: null,
      });

      const result = await service.validateUser('u_123');

      expect(result).toEqual(user);
    });

    it('should return null if user not found', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await service.validateUser('nonexistent');

      expect(result).toBeNull();
    });
  });

  describe('generateTokens', () => {
    it('should generate both access and refresh tokens', async () => {
      jest.spyOn(jwtService, 'signAsync')
        .mockResolvedValueOnce('access-token')
        .mockResolvedValueOnce('refresh-token');

      const tokens = await service['generateTokens']('u_123', 'test@example.com');

      expect(tokens).toEqual({
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      });

      expect(jwtService.signAsync).toHaveBeenCalledTimes(2);
    });
  });
});
