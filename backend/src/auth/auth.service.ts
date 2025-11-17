import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { SupabaseService } from '../common/supabase/supabase.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private supabase: SupabaseService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, password, fullName } = registerDto;

    // Verificar si el email ya existe
    const { data: existingUser } = await this.supabase
      .from('users')
      .select('user_id')
      .eq('email', email)
      .single();

    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear usuario
    const { data: user, error } = await this.supabase
      .from('users')
      .insert({
        email,
        full_name: fullName,
        password_hash: hashedPassword,
      })
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to create user: ${error.message}`);
    }

    // Crear configuración de usuario
    await this.supabase.from('user_settings').insert({
      user_id: user.user_id,
    });

    // Crear estadísticas de usuario
    await this.supabase.from('user_stats').insert({
      user_id: user.user_id,
    });

    // Generar tokens
    const tokens = await this.generateTokens(user.user_id, email);

    return {
      user: {
        userId: user.user_id,
        email: user.email,
        fullName: user.full_name,
      },
      ...tokens,
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Buscar usuario
    const { data: user } = await this.supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (!user || !user.password_hash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verificar password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Actualizar última actividad
    await this.supabase
      .from('users')
      .update({ last_active_at: new Date().toISOString() })
      .eq('user_id', user.user_id);

    // Generar tokens
    const tokens = await this.generateTokens(user.user_id, email);

    return {
      user: {
        userId: user.user_id,
        email: user.email,
        fullName: user.full_name,
        subscriptionTier: user.subscription_tier,
      },
      ...tokens,
    };
  }

  async googleLogin(user: any) {
    // Verificar si el usuario ya existe
    const { data: existingUser } = await this.supabase
      .from('users')
      .select('*')
      .eq('email', user.email)
      .single();

    let userId: string;

    if (existingUser) {
      userId = existingUser.user_id;

      // Actualizar última actividad
      await this.supabase
        .from('users')
        .update({ last_active_at: new Date().toISOString() })
        .eq('user_id', userId);
    } else {
      // Crear nuevo usuario
      const { data: newUser } = await this.supabase
        .from('users')
        .insert({
          email: user.email,
          full_name: user.firstName + ' ' + user.lastName,
          avatar_url: user.picture,
        })
        .select()
        .single();

      userId = newUser.user_id;

      // Crear conexión OAuth
      await this.supabase.from('user_oauth_connections').insert({
        user_id: userId,
        provider: 'google',
        provider_user_id: user.id,
      });

      // Crear configuración y estadísticas
      await this.supabase.from('user_settings').insert({ user_id: userId });
      await this.supabase.from('user_stats').insert({ user_id: userId });
    }

    // Generar tokens
    const tokens = await this.generateTokens(userId, user.email);

    return {
      user: {
        userId,
        email: user.email,
        fullName: user.firstName + ' ' + user.lastName,
      },
      ...tokens,
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const tokens = await this.generateTokens(payload.sub, payload.email);

      return tokens;
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  private async generateTokens(userId: string, email: string) {
    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(
        { sub: userId, email },
        {
          secret: this.configService.get<string>('JWT_SECRET'),
          expiresIn: this.configService.get<string>('JWT_EXPIRATION'),
        },
      ),
      this.jwtService.signAsync(
        { sub: userId, email },
        {
          secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
          expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRATION'),
        },
      ),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }

  async validateUser(userId: string) {
    const { data: user } = await this.supabase
      .from('users')
      .select('*')
      .eq('user_id', userId)
      .single();

    return user;
  }
}
