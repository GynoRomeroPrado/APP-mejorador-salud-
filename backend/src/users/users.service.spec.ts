import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { SupabaseService } from '../common/supabase/supabase.service';

describe('UsersService', () => {
  let service: UsersService;
  let supabaseService: jest.Mocked<SupabaseService>;

  const mockSupabaseResponse = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: SupabaseService,
          useValue: mockSupabaseResponse,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    supabaseService = module.get(SupabaseService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findById', () => {
    it('should return user by id', async () => {
      const user = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
        created_at: '2024-01-01T00:00:00Z',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: user,
        error: null,
      });

      const result = await service.findById('u_123');

      expect(result).toEqual(user);
      expect(mockSupabaseResponse.from).toHaveBeenCalledWith('users');
      expect(mockSupabaseResponse.select).toHaveBeenCalledWith('*');
      expect(mockSupabaseResponse.eq).toHaveBeenCalledWith('user_id', 'u_123');
    });

    it('should throw error if user not found', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'User not found' },
      });

      await expect(service.findById('nonexistent')).rejects.toThrow();
    });

    it('should throw error on database error', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Database error' },
      });

      await expect(service.findById('u_123')).rejects.toThrow();
    });
  });

  describe('findByEmail', () => {
    it('should return user by email', async () => {
      const user = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: user,
        error: null,
      });

      const result = await service.findByEmail('test@example.com');

      expect(result).toEqual(user);
      expect(mockSupabaseResponse.eq).toHaveBeenCalledWith(
        'email',
        'test@example.com',
      );
    });

    it('should throw error if user not found by email', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'User not found' },
      });

      await expect(
        service.findByEmail('nonexistent@example.com'),
      ).rejects.toThrow();
    });

    it('should handle case-sensitive email lookup', async () => {
      const user = {
        user_id: 'u_123',
        email: 'Test@Example.com',
        full_name: 'Test User',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: user,
        error: null,
      });

      const result = await service.findByEmail('Test@Example.com');

      expect(result.email).toBe('Test@Example.com');
    });
  });

  describe('updateProfile', () => {
    it('should update user profile successfully', async () => {
      const updateData = {
        full_name: 'Updated Name',
        height_cm: 175.0,
        weight_kg: 70.0,
      };

      const updatedUser = {
        user_id: 'u_123',
        email: 'test@example.com',
        ...updateData,
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: updatedUser,
        error: null,
      });

      const result = await service.updateProfile('u_123', updateData);

      expect(result).toEqual(updatedUser);
      expect(mockSupabaseResponse.update).toHaveBeenCalledWith(updateData);
      expect(mockSupabaseResponse.eq).toHaveBeenCalledWith('user_id', 'u_123');
    });

    it('should throw error if update fails', async () => {
      const updateData = { full_name: 'Updated Name' };

      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Update failed' },
      });

      await expect(
        service.updateProfile('u_123', updateData),
      ).rejects.toThrow();
    });

    it('should update only provided fields', async () => {
      const updateData = {
        height_cm: 180.0,
      };

      const updatedUser = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: 'Test User',
        height_cm: 180.0,
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: updatedUser,
        error: null,
      });

      const result = await service.updateProfile('u_123', updateData);

      expect(result.height_cm).toBe(180.0);
      expect(result.full_name).toBe('Test User'); // Unchanged
    });

    it('should update avatar URL', async () => {
      const updateData = {
        avatar_url: 'https://example.com/avatar.jpg',
      };

      const updatedUser = {
        user_id: 'u_123',
        email: 'test@example.com',
        avatar_url: 'https://example.com/avatar.jpg',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: updatedUser,
        error: null,
      });

      const result = await service.updateProfile('u_123', updateData);

      expect(result.avatar_url).toBe('https://example.com/avatar.jpg');
    });
  });

  describe('getUserStats', () => {
    it('should return user stats', async () => {
      const stats = {
        user_id: 'u_123',
        total_xp: 500,
        level: 5,
        current_streak: 7,
        longest_streak: 15,
        workouts_completed: 25,
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: stats,
        error: null,
      });

      const result = await service.getUserStats('u_123');

      expect(result).toEqual(stats);
      expect(mockSupabaseResponse.from).toHaveBeenCalledWith('user_stats');
      expect(mockSupabaseResponse.eq).toHaveBeenCalledWith('user_id', 'u_123');
    });

    it('should throw error if stats not found', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Stats not found' },
      });

      await expect(service.getUserStats('nonexistent')).rejects.toThrow();
    });

    it('should return stats with all fields', async () => {
      const stats = {
        user_id: 'u_123',
        total_xp: 1000,
        level: 10,
        current_streak: 30,
        longest_streak: 50,
        workouts_completed: 100,
        medications_taken: 200,
        total_sets: 500,
        total_volume: 50000.0,
        total_workout_minutes: 2000,
        total_calories_burned: 10000,
        average_workout_duration: 40,
        last_activity_date: '2024-01-15T10:00:00Z',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: stats,
        error: null,
      });

      const result = await service.getUserStats('u_123');

      expect(result.total_xp).toBe(1000);
      expect(result.level).toBe(10);
      expect(result.current_streak).toBe(30);
      expect(result.workouts_completed).toBe(100);
    });
  });

  describe('error handling', () => {
    it('should handle database connection errors', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Connection failed' },
      });

      await expect(service.findById('u_123')).rejects.toThrow();
    });

    it('should handle timeout errors', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Timeout' },
      });

      await expect(service.findByEmail('test@example.com')).rejects.toThrow();
    });

    it('should handle invalid data errors', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Invalid data' },
      });

      await expect(
        service.updateProfile('u_123', {}),
      ).rejects.toThrow();
    });
  });

  describe('data validation', () => {
    it('should handle null values in update', async () => {
      const updateData = {
        full_name: null,
        height_cm: null,
      };

      const updatedUser = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: null,
        height_cm: null,
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: updatedUser,
        error: null,
      });

      const result = await service.updateProfile('u_123', updateData);

      expect(result.full_name).toBeNull();
      expect(result.height_cm).toBeNull();
    });

    it('should handle empty strings', async () => {
      const updateData = {
        full_name: '',
      };

      const updatedUser = {
        user_id: 'u_123',
        email: 'test@example.com',
        full_name: '',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: updatedUser,
        error: null,
      });

      const result = await service.updateProfile('u_123', updateData);

      expect(result.full_name).toBe('');
    });
  });
});
