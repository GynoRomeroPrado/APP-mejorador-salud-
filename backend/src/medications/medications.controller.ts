import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { MedicationsService } from './medications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('medications')
@Controller('medications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}

  @Get()
  @ApiOperation({ summary: 'Obtener todos los medicamentos del usuario' })
  @ApiResponse({ status: 200, description: 'Lista de medicamentos' })
  async findAll(@Request() req) {
    return this.medicationsService.findAll(req.user.userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un medicamento por ID' })
  @ApiResponse({ status: 200, description: 'Medicamento encontrado' })
  @ApiResponse({ status: 404, description: 'Medicamento no encontrado' })
  async findOne(@Param('id') id: string) {
    return this.medicationsService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear nuevo medicamento' })
  @ApiResponse({ status: 201, description: 'Medicamento creado' })
  async create(@Request() req, @Body() createDto: any) {
    return this.medicationsService.create(req.user.userId, createDto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Actualizar medicamento' })
  @ApiResponse({ status: 200, description: 'Medicamento actualizado' })
  async update(@Param('id') id: string, @Body() updateDto: any) {
    return this.medicationsService.update(id, updateDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar medicamento' })
  @ApiResponse({ status: 200, description: 'Medicamento eliminado' })
  async remove(@Param('id') id: string) {
    return this.medicationsService.remove(id);
  }

  @Get('logs/all')
  @ApiOperation({ summary: 'Obtener logs de medicamentos' })
  @ApiResponse({ status: 200, description: 'Logs de medicamentos' })
  async getLogs(
    @Request() req,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.medicationsService.getLogs(
      req.user.userId,
      startDate,
      endDate,
    );
  }

  @Post('logs')
  @ApiOperation({ summary: 'Crear log de medicamento' })
  @ApiResponse({ status: 201, description: 'Log creado' })
  async createLog(@Body() logDto: any) {
    return this.medicationsService.createLog(logDto);
  }

  @Get('stats/summary')
  @ApiOperation({ summary: 'Obtener estadísticas de adherencia' })
  @ApiResponse({ status: 200, description: 'Estadísticas de adherencia' })
  async getStats(@Request() req, @Query('days') days?: number) {
    return this.medicationsService.getStats(req.user.userId, days);
  }
}
