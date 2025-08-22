
import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Calendar, Users, Clock, MapPin, Plus, Edit, Trash2 } from 'lucide-react';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

interface Class {
  class_id: string;
  class_name: string;
  course_title: string;
  course_id: string;
  schedule: string;
  max_students: number;
  enrolled_count: number;
  start_date: string;
  end_date: string;
  status: string;
}

interface Course {
  id: string;
  title: string;
}

interface Room {
  id: string;
  name: string;
}

const ProfessorClasses = () => {
  const [classes, setClasses] = useState<Class[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [rooms, setRooms] = useState<Room[]>([]);
  const [loading, setLoading] = useState(true);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    course_id: '',
    name: '',
    schedule: '',
    room_id: '',
    max_students: 30,
    start_date: '',
    end_date: ''
  });

  useEffect(() => {
    fetchClasses();
    fetchCourses();
    fetchRooms();
  }, []);

  const fetchClasses = async () => {
    try {
      const { data, error } = await supabase.rpc('get_professor_classes');
      
      if (error) throw error;
      
      setClasses(data || []);
    } catch (error) {
      console.error('Erro ao carregar turmas:', error);
      toast.error('Erro ao carregar turmas');
    } finally {
      setLoading(false);
    }
  };

  const fetchCourses = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data, error } = await supabase
        .from('courses')
        .select('id, title')
        .eq('professor_id', user.id)
        .eq('status', 'approved');
      
      if (error) throw error;
      setCourses(data || []);
    } catch (error) {
      console.error('Erro ao carregar cursos:', error);
    }
  };

  const fetchRooms = async () => {
    try {
      const { data, error } = await supabase
        .from('rooms')
        .select('id, name')
        .eq('is_active', true);
      
      if (error) throw error;
      setRooms(data || []);
    } catch (error) {
      console.error('Erro ao carregar salas:', error);
    }
  };

  const handleCreateClass = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      const { data, error } = await supabase.rpc('create_class', {
        p_course_id: formData.course_id,
        p_class_name: formData.name,
        p_schedule: formData.schedule,
        p_room_id: formData.room_id || null,
        p_max_students: formData.max_students,
        p_start_date: formData.start_date || null,
        p_end_date: formData.end_date || null
      });

      if (error) throw error;

      toast.success('Turma criada com sucesso!');
      setIsCreateModalOpen(false);
      setFormData({
        course_id: '',
        name: '',
        schedule: '',
        room_id: '',
        max_students: 30,
        start_date: '',
        end_date: ''
      });
      fetchClasses();
    } catch (error) {
      console.error('Erro ao criar turma:', error);
      toast.error('Erro ao criar turma');
    }
  };

  const getStatusBadge = (status: string) => {
    const statusConfig = {
      active: { label: 'Ativa', variant: 'default' as const },
      upcoming: { label: 'Próxima', variant: 'secondary' as const },
      finished: { label: 'Finalizada', variant: 'outline' as const }
    };

    const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.active;
    return <Badge variant={config.variant}>{config.label}</Badge>;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p>Carregando turmas...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold">Minhas Turmas</h1>
          <p className="text-muted-foreground">Gerencie suas turmas e alunos</p>
        </div>
        
        <Dialog open={isCreateModalOpen} onOpenChange={setIsCreateModalOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Nova Turma
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle>Criar Nova Turma</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleCreateClass} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="course_id">Curso</Label>
                <Select 
                  value={formData.course_id} 
                  onValueChange={(value) => setFormData({...formData, course_id: value})}
                  required
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione um curso" />
                  </SelectTrigger>
                  <SelectContent>
                    {courses.map((course) => (
                      <SelectItem key={course.id} value={course.id}>
                        {course.title}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="name">Nome da Turma</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  placeholder="Ex: Turma A - Manhã"
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="schedule">Horário</Label>
                <Input
                  id="schedule"
                  value={formData.schedule}
                  onChange={(e) => setFormData({...formData, schedule: e.target.value})}
                  placeholder="Ex: Seg, Qua, Sex - 08:00 às 10:00"
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="room_id">Sala (Opcional)</Label>
                <Select 
                  value={formData.room_id} 
                  onValueChange={(value) => setFormData({...formData, room_id: value})}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione uma sala" />
                  </SelectTrigger>
                  <SelectContent>
                    {rooms.map((room) => (
                      <SelectItem key={room.id} value={room.id}>
                        {room.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="max_students">Máximo de Alunos</Label>
                <Input
                  id="max_students"
                  type="number"
                  value={formData.max_students}
                  onChange={(e) => setFormData({...formData, max_students: parseInt(e.target.value)})}
                  min="1"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="start_date">Data de Início</Label>
                  <Input
                    id="start_date"
                    type="date"
                    value={formData.start_date}
                    onChange={(e) => setFormData({...formData, start_date: e.target.value})}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="end_date">Data de Fim</Label>
                  <Input
                    id="end_date"
                    type="date"
                    value={formData.end_date}
                    onChange={(e) => setFormData({...formData, end_date: e.target.value})}
                  />
                </div>
              </div>

              <Button type="submit" className="w-full">
                Criar Turma
              </Button>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      {classes.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Users className="h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">Nenhuma turma encontrada</h3>
            <p className="text-muted-foreground text-center mb-4">
              Você ainda não criou nenhuma turma. Crie sua primeira turma para começar a organizar seus alunos.
            </p>
            <Button onClick={() => setIsCreateModalOpen(true)}>
              <Plus className="mr-2 h-4 w-4" />
              Criar Primeira Turma
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {classes.map((classItem) => (
            <Card key={classItem.class_id} className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="flex justify-between items-start">
                  <div>
                    <CardTitle className="text-lg">{classItem.class_name}</CardTitle>
                    <p className="text-sm text-muted-foreground">{classItem.course_title}</p>
                  </div>
                  {getStatusBadge(classItem.status)}
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center text-sm">
                  <Clock className="mr-2 h-4 w-4 text-muted-foreground" />
                  {classItem.schedule}
                </div>
                
                <div className="flex items-center text-sm">
                  <Users className="mr-2 h-4 w-4 text-muted-foreground" />
                  {classItem.enrolled_count} / {classItem.max_students} alunos
                </div>

                {(classItem.start_date || classItem.end_date) && (
                  <div className="flex items-center text-sm">
                    <Calendar className="mr-2 h-4 w-4 text-muted-foreground" />
                    {classItem.start_date && new Date(classItem.start_date).toLocaleDateString('pt-BR')}
                    {classItem.start_date && classItem.end_date && ' - '}
                    {classItem.end_date && new Date(classItem.end_date).toLocaleDateString('pt-BR')}
                  </div>
                )}

                <div className="flex gap-2 pt-2">
                  <Button variant="outline" size="sm" className="flex-1">
                    <Edit className="mr-1 h-3 w-3" />
                    Editar
                  </Button>
                  <Button variant="outline" size="sm" className="flex-1">
                    <Users className="mr-1 h-3 w-3" />
                    Alunos
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default ProfessorClasses;
