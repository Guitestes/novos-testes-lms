
-- Função para aprovar curso
CREATE OR REPLACE FUNCTION public.approve_course(p_course_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar se o usuário é admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Apenas administradores podem aprovar cursos';
    END IF;
    
    -- Atualizar status do curso
    UPDATE public.courses 
    SET 
        status = 'approved',
        approved_by = auth.uid(),
        approved_at = NOW(),
        updated_at = NOW()
    WHERE id = p_course_id AND status = 'pending';
    
    -- Verificar se o curso foi encontrado e atualizado
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Curso não encontrado ou não está pendente';
    END IF;
    
    -- Criar notificação para o professor
    INSERT INTO public.notifications (user_id, message, type, link)
    SELECT 
        professor_id,
        'Seu curso "' || title || '" foi aprovado e está disponível para matrículas!',
        'course_approved',
        '/professor/courses/' || id
    FROM public.courses 
    WHERE id = p_course_id;
END;
$$;

-- Função para rejeitar curso
CREATE OR REPLACE FUNCTION public.reject_course(p_course_id UUID, p_rejection_reason TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar se o usuário é admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Apenas administradores podem rejeitar cursos';
    END IF;
    
    -- Verificar se foi fornecido um motivo
    IF p_rejection_reason IS NULL OR trim(p_rejection_reason) = '' THEN
        RAISE EXCEPTION 'É obrigatório fornecer um motivo para rejeição';
    END IF;
    
    -- Atualizar status do curso
    UPDATE public.courses 
    SET 
        status = 'rejected',
        approved_by = auth.uid(),
        approved_at = NOW(),
        rejection_reason = p_rejection_reason,
        updated_at = NOW()
    WHERE id = p_course_id AND status = 'pending';
    
    -- Verificar se o curso foi encontrado e atualizado
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Curso não encontrado ou não está pendente';
    END IF;
    
    -- Criar notificação para o professor
    INSERT INTO public.notifications (user_id, message, type, link)
    SELECT 
        professor_id,
        'Seu curso "' || title || '" foi rejeitado. Motivo: ' || p_rejection_reason,
        'course_rejected',
        '/professor/courses/' || id
    FROM public.courses 
    WHERE id = p_course_id;
END;
$$;
