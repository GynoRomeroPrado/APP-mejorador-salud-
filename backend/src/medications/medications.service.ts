import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

@Injectable()
export class MedicationsService {
  constructor(private supabase: SupabaseService) {}

  async findAll(userId: string) {
    const { data, error } = await this.supabase
      .from('medications')
      .select(`
        *,
        schedules:medication_schedules(*)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return data;
  }

  async findOne(medId: string) {
    const { data, error } = await this.supabase
      .from('medications')
      .select(`
        *,
        schedules:medication_schedules(*)
      `)
      .eq('med_id', medId)
      .single();

    if (error) throw error;

    return data;
  }

  async create(userId: string, createDto: any) {
    // Insert medication
    const { data: medication, error: medError } = await this.supabase
      .from('medications')
      .insert({
        user_id: userId,
        ...createDto,
      })
      .select()
      .single();

    if (medError) throw medError;

    // Insert schedules if provided
    if (createDto.schedules && createDto.schedules.length > 0) {
      const schedulesData = createDto.schedules.map((schedule: any) => ({
        med_id: medication.med_id,
        ...schedule,
      }));

      await this.supabase.from('medication_schedules').insert(schedulesData);
    }

    return this.findOne(medication.med_id);
  }

  async update(medId: string, updateDto: any) {
    const { data, error } = await this.supabase
      .from('medications')
      .update(updateDto)
      .eq('med_id', medId)
      .select()
      .single();

    if (error) throw error;

    return this.findOne(medId);
  }

  async remove(medId: string) {
    const { error } = await this.supabase
      .from('medications')
      .delete()
      .eq('med_id', medId);

    if (error) throw error;

    return { message: 'Medication deleted successfully' };
  }

  async getLogs(userId: string, startDate?: string, endDate?: string) {
    let query = this.supabase
      .from('medication_logs')
      .select(`
        *,
        medication:medications!inner(user_id)
      `)
      .eq('medication.user_id', userId)
      .order('scheduled_time', { ascending: false });

    if (startDate) {
      query = query.gte('scheduled_time', startDate);
    }

    if (endDate) {
      query = query.lte('scheduled_time', endDate);
    }

    const { data, error } = await query;

    if (error) throw error;

    return data;
  }

  async createLog(logDto: any) {
    const { data, error } = await this.supabase
      .from('medication_logs')
      .insert(logDto)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  async getStats(userId: string, days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const { data: logs } = await this.getLogs(
      userId,
      startDate.toISOString(),
    );

    const takenCount = logs?.filter((l) => l.status === 'taken').length || 0;
    const missedCount = logs?.filter((l) => l.status === 'missed').length || 0;
    const skippedCount = logs?.filter((l) => l.status === 'skipped').length || 0;
    const total = logs?.length || 0;

    const adherenceRate = total > 0 ? (takenCount / total) * 100 : 0;

    return {
      adherenceRate,
      takenCount,
      missedCount,
      skippedCount,
      totalLogs: total,
    };
  }
}
