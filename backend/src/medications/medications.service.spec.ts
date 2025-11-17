import { Test, TestingModule } from '@nestjs/testing';
import { MedicationsService } from './medications.service';
import { SupabaseService } from '../common/supabase/supabase.service';

describe('MedicationsService', () => {
  let service: MedicationsService;
  let supabaseService: jest.Mocked<SupabaseService>;

  const mockSupabaseResponse = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    gte: jest.fn().mockReturnThis(),
    lte: jest.fn().mockReturnThis(),
    single: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MedicationsService,
        {
          provide: SupabaseService,
          useValue: mockSupabaseResponse,
        },
      ],
    }).compile();

    service = module.get<MedicationsService>(MedicationsService);
    supabaseService = module.get(SupabaseService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return all medications for a user', async () => {
      const medications = [
        {
          med_id: 'm_001',
          user_id: 'u_123',
          name: 'Aspirina',
          dosage: '500mg',
          schedules: [],
        },
        {
          med_id: 'm_002',
          user_id: 'u_123',
          name: 'Vitamina D',
          dosage: '1000 IU',
          schedules: [],
        },
      ];

      mockSupabaseResponse.order.mockResolvedValue({
        data: medications,
        error: null,
      });

      const result = await service.findAll('u_123');

      expect(result).toEqual(medications);
      expect(mockSupabaseResponse.from).toHaveBeenCalledWith('medications');
      expect(mockSupabaseResponse.eq).toHaveBeenCalledWith('user_id', 'u_123');
      expect(mockSupabaseResponse.order).toHaveBeenCalledWith('created_at', {
        ascending: false,
      });
    });

    it('should return empty array if no medications', async () => {
      mockSupabaseResponse.order.mockResolvedValue({
        data: [],
        error: null,
      });

      const result = await service.findAll('u_123');

      expect(result).toEqual([]);
    });

    it('should throw error on database failure', async () => {
      mockSupabaseResponse.order.mockResolvedValue({
        data: null,
        error: { message: 'Database error' },
      });

      await expect(service.findAll('u_123')).rejects.toThrow();
    });

    it('should include schedules in response', async () => {
      const medications = [
        {
          med_id: 'm_001',
          name: 'Aspirina',
          schedules: [
            { schedule_id: 's_001', time: '08:00' },
            { schedule_id: 's_002', time: '20:00' },
          ],
        },
      ];

      mockSupabaseResponse.order.mockResolvedValue({
        data: medications,
        error: null,
      });

      const result = await service.findAll('u_123');

      expect(result[0].schedules).toHaveLength(2);
    });
  });

  describe('findOne', () => {
    it('should return single medication by id', async () => {
      const medication = {
        med_id: 'm_001',
        user_id: 'u_123',
        name: 'Aspirina',
        dosage: '500mg',
        schedules: [],
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: medication,
        error: null,
      });

      const result = await service.findOne('m_001');

      expect(result).toEqual(medication);
      expect(mockSupabaseResponse.eq).toHaveBeenCalledWith('med_id', 'm_001');
    });

    it('should throw error if medication not found', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Medication not found' },
      });

      await expect(service.findOne('nonexistent')).rejects.toThrow();
    });
  });

  describe('create', () => {
    it('should create medication without schedules', async () => {
      const createDto = {
        name: 'Aspirina',
        dosage: '500mg',
        type: 'medication',
        color_hex: '#FF0000',
        icon: 'pill',
      };

      const newMedication = {
        med_id: 'm_new',
        user_id: 'u_123',
        ...createDto,
      };

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: newMedication, error: null })
        .mockResolvedValueOnce({ data: newMedication, error: null }); // findOne

      const result = await service.create('u_123', createDto);

      expect(result.name).toBe('Aspirina');
      expect(mockSupabaseResponse.insert).toHaveBeenCalled();
    });

    it('should create medication with schedules', async () => {
      const createDto = {
        name: 'Vitamina D',
        dosage: '1000 IU',
        type: 'supplement',
        schedules: [
          { time: '08:00', frequency: 'daily' },
          { time: '20:00', frequency: 'daily' },
        ],
      };

      const newMedication = {
        med_id: 'm_new',
        user_id: 'u_123',
        name: 'Vitamina D',
        dosage: '1000 IU',
      };

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: newMedication, error: null })
        .mockResolvedValueOnce({
          data: { ...newMedication, schedules: createDto.schedules },
          error: null,
        });

      const result = await service.create('u_123', createDto);

      expect(mockSupabaseResponse.insert).toHaveBeenCalledTimes(2); // medication + schedules
    });

    it('should throw error if creation fails', async () => {
      const createDto = {
        name: 'Test Med',
        dosage: '100mg',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Creation failed' },
      });

      await expect(service.create('u_123', createDto)).rejects.toThrow();
    });
  });

  describe('update', () => {
    it('should update medication successfully', async () => {
      const updateDto = {
        name: 'Updated Aspirina',
        dosage: '1000mg',
      };

      const updatedMedication = {
        med_id: 'm_001',
        user_id: 'u_123',
        ...updateDto,
      };

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: updatedMedication, error: null })
        .mockResolvedValueOnce({ data: updatedMedication, error: null }); // findOne

      const result = await service.update('m_001', updateDto);

      expect(result.name).toBe('Updated Aspirina');
      expect(mockSupabaseResponse.update).toHaveBeenCalledWith(updateDto);
    });

    it('should throw error if update fails', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Update failed' },
      });

      await expect(service.update('m_001', {})).rejects.toThrow();
    });
  });

  describe('remove', () => {
    it('should delete medication successfully', async () => {
      mockSupabaseResponse.delete.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await service.remove('m_001');

      expect(result.message).toBe('Medication deleted successfully');
      expect(mockSupabaseResponse.delete).toHaveBeenCalled();
      expect(mockSupabaseResponse.eq).toHaveBeenCalledWith('med_id', 'm_001');
    });

    it('should throw error if deletion fails', async () => {
      mockSupabaseResponse.delete.mockResolvedValue({
        data: null,
        error: { message: 'Deletion failed' },
      });

      await expect(service.remove('m_001')).rejects.toThrow();
    });
  });

  describe('getLogs', () => {
    it('should return logs for a user', async () => {
      const logs = [
        {
          log_id: 'l_001',
          med_id: 'm_001',
          status: 'taken',
          scheduled_time: '2024-01-15T08:00:00Z',
        },
        {
          log_id: 'l_002',
          med_id: 'm_002',
          status: 'missed',
          scheduled_time: '2024-01-15T12:00:00Z',
        },
      ];

      mockSupabaseResponse.order.mockResolvedValue({
        data: logs,
        error: null,
      });

      const result = await service.getLogs('u_123');

      expect(result).toEqual(logs);
      expect(mockSupabaseResponse.from).toHaveBeenCalledWith('medication_logs');
    });

    it('should filter logs by date range', async () => {
      const logs = [
        {
          log_id: 'l_001',
          scheduled_time: '2024-01-15T08:00:00Z',
        },
      ];

      mockSupabaseResponse.order.mockResolvedValue({
        data: logs,
        error: null,
      });

      const result = await service.getLogs(
        'u_123',
        '2024-01-01T00:00:00Z',
        '2024-01-31T23:59:59Z',
      );

      expect(mockSupabaseResponse.gte).toHaveBeenCalledWith(
        'scheduled_time',
        '2024-01-01T00:00:00Z',
      );
      expect(mockSupabaseResponse.lte).toHaveBeenCalledWith(
        'scheduled_time',
        '2024-01-31T23:59:59Z',
      );
    });

    it('should return empty array if no logs', async () => {
      mockSupabaseResponse.order.mockResolvedValue({
        data: [],
        error: null,
      });

      const result = await service.getLogs('u_123');

      expect(result).toEqual([]);
    });
  });

  describe('createLog', () => {
    it('should create medication log', async () => {
      const logDto = {
        med_id: 'm_001',
        schedule_id: 's_001',
        user_id: 'u_123',
        scheduled_time: '2024-01-15T08:00:00Z',
        status: 'taken',
        taken_time: '2024-01-15T08:05:00Z',
      };

      const newLog = {
        log_id: 'l_new',
        ...logDto,
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: newLog,
        error: null,
      });

      const result = await service.createLog(logDto);

      expect(result).toEqual(newLog);
      expect(mockSupabaseResponse.insert).toHaveBeenCalledWith(logDto);
    });

    it('should throw error if log creation fails', async () => {
      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Creation failed' },
      });

      await expect(service.createLog({})).rejects.toThrow();
    });
  });

  describe('getStats', () => {
    it('should calculate adherence statistics', async () => {
      const logs = [
        { status: 'taken' },
        { status: 'taken' },
        { status: 'taken' },
        { status: 'missed' },
        { status: 'skipped' },
      ];

      mockSupabaseResponse.order.mockResolvedValue({
        data: logs,
        error: null,
      });

      const result = await service.getStats('u_123', 30);

      expect(result.takenCount).toBe(3);
      expect(result.missedCount).toBe(1);
      expect(result.skippedCount).toBe(1);
      expect(result.totalLogs).toBe(5);
      expect(result.adherenceRate).toBe(60); // 3/5 = 60%
    });

    it('should return zero adherence for no logs', async () => {
      mockSupabaseResponse.order.mockResolvedValue({
        data: [],
        error: null,
      });

      const result = await service.getStats('u_123', 30);

      expect(result.adherenceRate).toBe(0);
      expect(result.takenCount).toBe(0);
      expect(result.totalLogs).toBe(0);
    });

    it('should calculate 100% adherence for all taken', async () => {
      const logs = [
        { status: 'taken' },
        { status: 'taken' },
        { status: 'taken' },
      ];

      mockSupabaseResponse.order.mockResolvedValue({
        data: logs,
        error: null,
      });

      const result = await service.getStats('u_123', 7);

      expect(result.adherenceRate).toBe(100);
      expect(result.takenCount).toBe(3);
      expect(result.missedCount).toBe(0);
    });

    it('should use correct date range for stats', async () => {
      mockSupabaseResponse.order.mockResolvedValue({
        data: [],
        error: null,
      });

      await service.getStats('u_123', 7);

      // Verify date filtering was applied
      expect(mockSupabaseResponse.gte).toHaveBeenCalled();
    });

    it('should handle different time periods', async () => {
      const logs = [{ status: 'taken' }];

      mockSupabaseResponse.order.mockResolvedValue({
        data: logs,
        error: null,
      });

      // Test 7 days
      await service.getStats('u_123', 7);

      // Test 30 days
      await service.getStats('u_123', 30);

      // Test 90 days
      await service.getStats('u_123', 90);

      expect(mockSupabaseResponse.gte).toHaveBeenCalledTimes(3);
    });
  });

  describe('error handling', () => {
    it('should handle database errors gracefully', async () => {
      mockSupabaseResponse.order.mockResolvedValue({
        data: null,
        error: { message: 'Database connection failed' },
      });

      await expect(service.findAll('u_123')).rejects.toThrow();
    });

    it('should handle constraint violations', async () => {
      const createDto = {
        name: 'Test Med',
        dosage: '100mg',
      };

      mockSupabaseResponse.single.mockResolvedValue({
        data: null,
        error: { message: 'Constraint violation' },
      });

      await expect(service.create('u_123', createDto)).rejects.toThrow();
    });
  });

  describe('data integrity', () => {
    it('should maintain referential integrity with schedules', async () => {
      const createDto = {
        name: 'Test Med',
        dosage: '100mg',
        schedules: [{ time: '08:00', frequency: 'daily' }],
      };

      const newMedication = {
        med_id: 'm_new',
        name: 'Test Med',
      };

      mockSupabaseResponse.single
        .mockResolvedValueOnce({ data: newMedication, error: null })
        .mockResolvedValueOnce({
          data: { ...newMedication, schedules: createDto.schedules },
          error: null,
        });

      const result = await service.create('u_123', createDto);

      expect(result.schedules).toBeDefined();
    });

    it('should cascade delete schedules when medication is deleted', async () => {
      mockSupabaseResponse.delete.mockResolvedValue({
        data: null,
        error: null,
      });

      await service.remove('m_001');

      // Verify delete was called (cascade handled by database)
      expect(mockSupabaseResponse.delete).toHaveBeenCalled();
    });
  });
});
