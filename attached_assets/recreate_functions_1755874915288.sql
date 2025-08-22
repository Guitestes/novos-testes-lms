-- Script SQL para recriar funções
-- Gerado automaticamente a partir de funcoes_completas.json
-- Data: 2025-08-22T12:44:38.761Z

-- Remover todas as funções existentes
DROP FUNCTION IF EXISTS public.calculate_campaign_roi(p_campaign_id uuid) CASCADE;
DROP FUNCTION IF EXISTS public.calculate_lead_score(lead_uuid uuid) CASCADE;
DROP FUNCTION IF EXISTS public.check_contract_expirations() CASCADE;
DROP FUNCTION IF EXISTS public.check_low_attendance() CASCADE;
DROP FUNCTION IF EXISTS public.check_schedule_conflict() CASCADE;
DROP FUNCTION IF EXISTS public.convert_lead_to_user(lead_uuid uuid, user_uuid uuid) CASCADE;
DROP FUNCTION IF EXISTS public.convert_lead_to_user(p_lead_id uuid, p_password text) CASCADE;
DROP FUNCTION IF EXISTS public.create_ticket_status_change_notification() CASCADE;
DROP FUNCTION IF EXISTS public.ensure_user_profile() CASCADE;
DROP FUNCTION IF EXISTS public.execute_request_action(p_request_id uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_all_users() CASCADE;
DROP FUNCTION IF EXISTS public.get_document_by_auth_code(auth_code text) CASCADE;
DROP FUNCTION IF EXISTS public.get_event_targets_for_course(p_course_id uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_provider_performance() CASCADE;
DROP FUNCTION IF EXISTS public.get_teams_for_user(user_id uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_final_grades(user_id_param uuid, course_id_param uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_transcript_data(user_id_param uuid) CASCADE;
DROP FUNCTION IF EXISTS public.get_users_with_roles() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.handle_professor_details_update() CASCADE;
DROP FUNCTION IF EXISTS public.is_admin() CASCADE;
DROP FUNCTION IF EXISTS public.is_admin(user_id uuid) CASCADE;
DROP FUNCTION IF EXISTS public.listar_colunas() CASCADE;
DROP FUNCTION IF EXISTS public.log_completed_class_hours() CASCADE;
DROP FUNCTION IF EXISTS public.moddatetime() CASCADE;
DROP FUNCTION IF EXISTS public.set_user_roles(target_user_id uuid, make_admin boolean, make_professor boolean) CASCADE;
DROP FUNCTION IF EXISTS public.sync_professor_roles() CASCADE;
DROP FUNCTION IF EXISTS public.sync_profile_from_auth() CASCADE;
DROP FUNCTION IF EXISTS public.trigger_set_timestamp() CASCADE;
DROP FUNCTION IF EXISTS public.update_dropout_students() CASCADE;
DROP FUNCTION IF EXISTS public.update_email_metrics(p_campaign_id uuid, p_metric_name character varying, p_value numeric) CASCADE;
DROP FUNCTION IF EXISTS public.update_marketing_timestamp() CASCADE;
DROP FUNCTION IF EXISTS public.update_past_due_classes_status() CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS public.update_user_role(user_email text, new_role text) CASCADE;

-- Funções do schema: public
-- Total: 35 funções (24 normais, 11 triggers)

-- Funções normais
-- Função: calculate_campaign_roi
-- Retorna: numeric
-- Argumentos: p_campaign_id uuid
CREATE OR REPLACE FUNCTION public.calculate_campaign_roi(p_campaign_id uuid)
 RETURNS numeric
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_investment decimal(10,2);
    v_revenue decimal(10,2);
    v_roi decimal(10,2);
BEGIN
    -- Buscar investimento da campanha
    SELECT budget INTO v_investment 
    FROM public.marketing_campaigns 
    WHERE id = p_campaign_id;
    
    -- Calcular receita dos leads convertidos desta campanha
    SELECT COALESCE(SUM(conversion_value), 0) INTO v_revenue
    FROM public.leads 
    WHERE source = (SELECT name FROM public.marketing_campaigns WHERE id = p_campaign_id)
    AND status = 'converted';
    
    -- Calcular ROI
    IF v_investment > 0 THEN
        v_roi := ((v_revenue - v_investment) / v_investment) * 100;
    ELSE
        v_roi := 0;
    END IF;
    
    RETURN v_roi;
END;
$function$;


-- Função: calculate_lead_score
-- Retorna: integer
-- Argumentos: lead_uuid uuid
CREATE OR REPLACE FUNCTION public.calculate_lead_score(lead_uuid uuid)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    score INTEGER := 0;
    lead_record RECORD;
    interaction_count INTEGER;
BEGIN
    -- Buscar dados do lead
    SELECT * INTO lead_record FROM public.leads WHERE id = lead_uuid;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    -- Pontuação baseada na origem
    CASE lead_record.source
        WHEN 'Google Ads' THEN score := score + 10;
        WHEN 'Facebook Ads' THEN score := score + 8;
        WHEN 'Indicação' THEN score := score + 15;
        WHEN 'Site' THEN score := score + 5;
        ELSE score := score + 3;
    END CASE;

    -- Pontuação baseada em interações
    SELECT COUNT(*) INTO interaction_count 
    FROM public.lead_interactions 
    WHERE lead_id = lead_uuid;

    score := score + (interaction_count * 5);

    -- Atualizar o score no banco
    UPDATE public.leads SET score = score WHERE id = lead_uuid;

    RETURN score;
END;
$function$;
-- Função: check_contract_expirations
-- Retorna: void
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.check_contract_expirations()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    admin_user_id UUID;
    expiring_contract RECORD;
BEGIN
    FOR expiring_contract IN
        SELECT id, title, end_date, provider_id
        FROM public.contracts
        WHERE end_date BETWEEN NOW() AND NOW() + INTERVAL '30 days'
        AND status = 'active'
    LOOP
        FOR admin_user_id IN
            SELECT id FROM public.profiles WHERE role = 'admin'
        LOOP
            INSERT INTO public.notifications (user_id, message, type, link)
            VALUES (
                admin_user_id,
                'O contrato "' || expiring_contract.title || '" com o prestador ' || (SELECT name FROM public.service_providers WHERE id = expiring_contract.provider_id) || ' está próximo do vencimento em ' || to_char(expiring_contract.end_date, 'DD/MM/YYYY') || '.',
                'contract_expiry',
                '/admin/service-providers'
            );
        END LOOP;
    END LOOP;
END;
$function$;
-- Função: check_low_attendance
-- Retorna: void
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.check_low_attendance()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    class_record RECORD;
    student_record RECORD;
    attendance_threshold NUMERIC := 75.0; -- Limite de 75%
BEGIN
    -- Itera sobre todas as turmas ativas (que ainda não terminaram)
    FOR class_record IN
        SELECT id FROM public.classes WHERE end_date IS NULL OR end_date >= CURRENT_DATE
    LOOP
        -- Para cada turma, obtém o resumo de frequência dos alunos
        FOR student_record IN
            SELECT * FROM reports.get_student_attendance_summary(class_record.id)
        LOOP
            -- Verifica se a taxa de presença está abaixo do limite
            IF student_record.attendance_rate < attendance_threshold THEN
                -- Verifica se já existe um alerta para este aluno, nesta turma, no dia de hoje
                IF NOT EXISTS (
                    SELECT 1
                    FROM public.low_attendance_alerts
                    WHERE user_id = student_record.user_id
                      AND class_id = class_record.id
                      AND alert_date = CURRENT_DATE
                ) THEN
                    -- Se não houver alerta hoje, insere um novo registro
                    INSERT INTO public.low_attendance_alerts (user_id, class_id, attendance_rate)
                    VALUES (student_record.user_id, class_record.id, student_record.attendance_rate);
                END IF;
            END IF;
        END LOOP;
    END LOOP;
END;
$function$;
-- Função: convert_lead_to_user
-- Retorna: boolean
-- Argumentos: lead_uuid uuid, user_uuid uuid
CREATE OR REPLACE FUNCTION public.convert_lead_to_user(lead_uuid uuid, user_uuid uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Atualizar o lead como convertido
    UPDATE public.leads 
    SET 
        status = 'converted',
        conversion_date = NOW(),
        converted_to_user_id = user_uuid,
        updated_at = NOW()
    WHERE id = lead_uuid;

    RETURN FOUND;
END;
$function$;
-- Função: convert_lead_to_user
-- Retorna: uuid
-- Argumentos: p_lead_id uuid, p_password text DEFAULT NULL::text
CREATE OR REPLACE FUNCTION public.convert_lead_to_user(p_lead_id uuid, p_password text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_lead_data record;
    v_user_id uuid;
BEGIN
    -- Buscar dados do lead
    SELECT * INTO v_lead_data FROM public.leads WHERE id = p_lead_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lead not found';
    END IF;
    
    -- Verificar se já não foi convertido
    IF v_lead_data.status = 'converted' THEN
        RAISE EXCEPTION 'Lead already converted';
    END IF;
    
    -- Criar usuário no auth (se necessário implementar integração)
    -- Por enquanto, criar perfil diretamente
    INSERT INTO public.profiles (
        id,
        name,
        email,
        role,
        phone
    ) VALUES (
        gen_random_uuid(),
        v_lead_data.name,
        v_lead_data.email,
        'student',
        v_lead_data.phone
    ) RETURNING id INTO v_user_id;
    
    -- Atualizar status do lead
    UPDATE public.leads 
    SET status = 'converted', 
        converted_at = now(),
        updated_at = now()
    WHERE id = p_lead_id;
    
    RETURN v_user_id;
END;
$function$;
-- Função: execute_request_action
-- Retorna: void
-- Argumentos: p_request_id uuid
CREATE OR REPLACE FUNCTION public.execute_request_action(p_request_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_request_type TEXT;
  v_user_id UUID;
BEGIN
  -- 1. Obter os detalhes da solicitação
  SELECT request_type, user_id INTO v_request_type, v_user_id
  FROM public.administrative_requests
  WHERE id = p_request_id;

  -- 2. Executar a ação com base no tipo de solicitação
  IF v_request_type = 'Trancamento' THEN
    -- Atualiza todas as matrículas ativas do usuário para 'trancado'
    UPDATE public.enrollments
    SET status = 'locked'
    WHERE user_id = v_user_id AND status = 'active';

    -- Opcional: Adicionar um log ou notificação sobre a ação
    RAISE NOTICE 'Matrículas do usuário % foram trancadas devido à aprovação do ticket %', v_user_id, p_request_id;
  END IF;

  -- Outros tipos de ações automáticas podem ser adicionados aqui
  -- ELSIF v_request_type = 'Outro_Tipo' THEN
  --   -- Lógica para outro tipo de ação
  -- END IF;
END;
$function$;
-- Função: get_all_users
-- Retorna: TABLE(id uuid, name text, email text, role text, created_at timestamp with time zone, avatar_url text)
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.get_all_users()
 RETURNS TABLE(id uuid, name text, email text, role text, created_at timestamp with time zone, avatar_url text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    -- Verificar se o usuário é admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Acesso negado: apenas administradores podem acessar todos os usuários';
    END IF;
    
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.email,
        COALESCE(p.role, 'student') as role,
        p.created_at,
        p.avatar_url
    FROM public.profiles p
    ORDER BY p.created_at DESC;
END;
$function$;
-- Função: get_document_by_auth_code
-- Retorna: SETOF documents
-- Argumentos: auth_code text
CREATE OR REPLACE FUNCTION public.get_document_by_auth_code(auth_code text)
 RETURNS SETOF documents
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- SECURITY DEFINER permite que esta função contorne a RLS para encontrar o documento.
    -- Isso é seguro porque ela só retorna documentos que correspondem ao código exato.
    RETURN QUERY
    SELECT * FROM public.documents
    WHERE authentication_code = auth_code;
END;
$function$;
-- Função: get_event_targets_for_course
-- Retorna: TABLE(target_id uuid, target_name text, target_type text)
-- Argumentos: p_course_id uuid
CREATE OR REPLACE FUNCTION public.get_event_targets_for_course(p_course_id uuid)
 RETURNS TABLE(target_id uuid, target_name text, target_type text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- This function should only be callable by an admin.
    IF (SELECT role FROM public.profiles WHERE id = auth.uid()) <> 'admin' THEN
        RAISE EXCEPTION 'Only admins can perform this action.';
    END IF;

    -- Return all classes associated with the course
    RETURN QUERY
    SELECT
        c.id AS target_id,
        c.name AS target_name,
        'class' AS target_type
    FROM
        public.classes c
    WHERE
        c.course_id = p_course_id;

    -- Return all students enrolled in any class of that course
    RETURN QUERY
    SELECT
        p.id AS target_id,
        p.name AS target_name,
        'student' AS target_type
    FROM
        public.profiles p
    JOIN
        public.enrollments e ON p.id = e.user_id
    JOIN
        public.classes c ON e.class_id = c.id
    WHERE
        c.course_id = p_course_id;
END;
$function$;
-- Função: get_provider_performance
-- Retorna: TABLE(provider_id uuid, provider_name text, average_score numeric, total_contracts bigint)
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.get_provider_performance()
 RETURNS TABLE(provider_id uuid, provider_name text, average_score numeric, total_contracts bigint)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        sp.id AS provider_id,
        sp.name AS provider_name,
        AVG(c.evaluation_score) AS average_score,
        COUNT(c.id) AS total_contracts
    FROM
        public.service_providers sp
    LEFT JOIN
        public.contracts c ON sp.id = c.provider_id
    GROUP BY
        sp.id, sp.name
    ORDER BY
        average_score DESC NULLS LAST;
END;
$function$;
-- Função: get_teams_for_user
-- Retorna: TABLE(team_id uuid)
-- Argumentos: user_id uuid
CREATE OR REPLACE FUNCTION public.get_teams_for_user(user_id uuid)
 RETURNS TABLE(team_id uuid)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  SELECT team_id
  FROM public.members
  WHERE user_id = get_teams_for_user.user_id
$function$;
-- Função: get_user_final_grades
-- Retorna: TABLE(user_id uuid, user_name text, course_title text, quiz_title text, score numeric)
-- Argumentos: user_id_param uuid, course_id_param uuid
CREATE OR REPLACE FUNCTION public.get_user_final_grades(user_id_param uuid, course_id_param uuid)
 RETURNS TABLE(user_id uuid, user_name text, course_title text, quiz_title text, score numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        c.title,
        q.title,
        qa.score
    FROM
        public.quiz_attempts AS qa
    JOIN
        public.profiles AS p ON qa.user_id = p.id
    JOIN
        public.quizzes AS q ON qa.quiz_id = q.id
    JOIN
        public.courses AS c ON q.course_id = c.id
    WHERE
        qa.user_id = user_id_param AND q.course_id = course_id_param;
END;
$function$;
-- Função: get_user_transcript_data
-- Retorna: TABLE(course_id uuid, course_title text, enrollment_status text, final_grade numeric, completion_date timestamp with time zone)
-- Argumentos: user_id_param uuid
CREATE OR REPLACE FUNCTION public.get_user_transcript_data(user_id_param uuid)
 RETURNS TABLE(course_id uuid, course_title text, enrollment_status text, final_grade numeric, completion_date timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    WITH course_grades AS (
        -- Primeiro, calcular a nota média para cada curso/usuário que tem notas
        SELECT
            q.course_id,
            qa.user_id,
            AVG(qa.score) as average_score
        FROM
            public.quiz_attempts AS qa
        JOIN
            public.quizzes AS q ON qa.quiz_id = q.id
        WHERE
            qa.user_id = user_id_param
        GROUP BY
            q.course_id, qa.user_id
    )
    -- Agora, junte com as matrículas para obter o histórico completo
    SELECT
        c.id as course_id,
        c.title as course_title,
        CASE
            WHEN e.completed_at IS NOT NULL THEN 'Concluído'
            WHEN e.progress > 0 THEN 'Em Andamento'
            ELSE 'Inscrito'
        END as enrollment_status,
        ROUND(cg.average_score, 2) as final_grade,
        e.completed_at as completion_date
    FROM
        public.enrollments AS e
    JOIN
        public.courses AS c ON e.course_id = c.id
    LEFT JOIN
        course_grades AS cg ON e.course_id = cg.course_id AND e.user_id = cg.user_id
    WHERE
        e.user_id = user_id_param
    ORDER BY
        e.enrolled_at DESC;
END;
$function$;
-- Função: get_users_with_roles
-- Retorna: TABLE(id uuid, name text, email text, is_admin boolean, is_professor boolean)
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.get_users_with_roles()
 RETURNS TABLE(id uuid, name text, email text, is_admin boolean, is_professor boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- This function should only be callable by admins.
    -- The check is performed in RLS policies on the calling frontend or API layer.
    -- For direct calls, ensure the caller has appropriate permissions.
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.email,
        (p.role = 'admin') AS is_admin,
        EXISTS (SELECT 1 FROM public.professor_details pd WHERE pd.user_id = p.id) AS is_professor
    FROM
        public.profiles p;
END;
$function$;
-- Função: is_admin
-- Retorna: boolean
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
BEGIN
    IF auth.uid() IS NULL THEN
        RETURN FALSE;
    END IF;
    
    RETURN EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$function$;
-- Função: is_admin
-- Retorna: boolean
-- Argumentos: user_id uuid
CREATE OR REPLACE FUNCTION public.is_admin(user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
SELECT EXISTS (
  SELECT 1 FROM public.profiles
  WHERE id = user_id AND role = 'admin'
);
$function$;
-- Função: listar_colunas
-- Retorna: TABLE(table_name text, column_name text, data_type text)
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.listar_colunas()
 RETURNS TABLE(table_name text, column_name text, data_type text)
 LANGUAGE sql
AS $function$
  select 
    table_name, 
    column_name, 
    data_type
  from information_schema.columns
  where table_schema = 'public';
$function$;
-- Função: set_user_roles
-- Retorna: void
-- Argumentos: target_user_id uuid, make_admin boolean, make_professor boolean
CREATE OR REPLACE FUNCTION public.set_user_roles(target_user_id uuid, make_admin boolean, make_professor boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    current_role TEXT;
BEGIN
    -- This function should only be callable by an admin.
    -- We can add an explicit check here for safety.
    IF (SELECT role FROM public.profiles WHERE id = auth.uid()) <> 'admin' THEN
        RAISE EXCEPTION 'Only admins can change user roles.';
    END IF;

    -- Set admin role
    IF make_admin THEN
        UPDATE public.profiles SET role = 'admin' WHERE id = target_user_id;
    ELSE
        -- If they are not being made an admin, what should their role be?
        -- Let's set it to 'student' if it's currently 'admin'.
        UPDATE public.profiles SET role = 'student' WHERE id = target_user_id AND role = 'admin';
    END IF;

    -- Set professor role
    IF make_professor THEN
        -- Insert into professor_details if not already there (UPSERT)
        INSERT INTO public.professor_details (user_id, bio, specialization)
        VALUES (target_user_id, 'Professor bio placeholder.', 'Specialization placeholder.')
        ON CONFLICT (user_id) DO NOTHING;
    ELSE
        -- Remove from professor_details if they exist
        DELETE FROM public.professor_details WHERE user_id = target_user_id;
    END IF;
END;
$function$;
-- Função: sync_professor_roles
-- Retorna: void
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.sync_professor_roles()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    prof_record RECORD;
BEGIN
    -- Atualizar metadados dos usuários professores
    FOR prof_record IN 
        SELECT id, email, role 
        FROM public.profiles 
        WHERE role = 'professor'
    LOOP
        -- Atualizar user_metadata com o role de professor
        UPDATE auth.users 
        SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', 'professor')
        WHERE id = prof_record.id;
        
        RAISE NOTICE 'Sincronizado role de professor para usuário: %', prof_record.email;
    END LOOP;
END;
$function$;
-- Função: update_dropout_students
-- Retorna: void
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.update_dropout_students()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Atualiza o status para 'inactive' para matrículas ativas de usuários
    -- que não fazem login há mais de 30 dias.
    WITH inactive_user_ids AS (
        SELECT id
        FROM auth.users
        WHERE last_sign_in_at < (NOW() - INTERVAL '30 days')
    )
    UPDATE public.enrollments
    SET status = 'inactive'
    WHERE
        user_id IN (SELECT id FROM inactive_user_ids)
        AND status = 'active';
END;
$function$;
-- Função: update_email_metrics
-- Retorna: void
-- Argumentos: p_campaign_id uuid, p_metric_name character varying, p_value numeric
CREATE OR REPLACE FUNCTION public.update_email_metrics(p_campaign_id uuid, p_metric_name character varying, p_value numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    INSERT INTO public.campaign_metrics (
        campaign_id,
        metric_name,
        metric_value,
        metric_date
    ) VALUES (
        p_campaign_id,
        p_metric_name,
        p_value,
        CURRENT_DATE
    );
    
    -- Atualizar contadores na tabela de campanhas de email
    CASE p_metric_name
        WHEN 'delivered' THEN
            UPDATE public.email_campaigns 
            SET delivered_count = delivered_count + p_value::integer
            WHERE campaign_id = p_campaign_id;
        WHEN 'opened' THEN
            UPDATE public.email_campaigns 
            SET opened_count = opened_count + p_value::integer
            WHERE campaign_id = p_campaign_id;
        WHEN 'clicked' THEN
            UPDATE public.email_campaigns 
            SET clicked_count = clicked_count + p_value::integer
            WHERE campaign_id = p_campaign_id;
        WHEN 'bounced' THEN
            UPDATE public.email_campaigns 
            SET bounced_count = bounced_count + p_value::integer
            WHERE campaign_id = p_campaign_id;
        WHEN 'unsubscribed' THEN
            UPDATE public.email_campaigns 
            SET unsubscribed_count = unsubscribed_count + p_value::integer
            WHERE campaign_id = p_campaign_id;
    END CASE;
END;
$function$;
-- Função: update_past_due_classes_status
-- Retorna: void
-- Argumentos: nenhum
CREATE OR REPLACE FUNCTION public.update_past_due_classes_status()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Find all calendar events that ended in the past and are still 'scheduled'
    -- and update their status to 'completed'.
    UPDATE public.calendar_events
    SET status = 'completed'
    WHERE end_time < NOW() AND status = 'scheduled';
END;
$function$;
-- Função: update_user_role
-- Retorna: boolean
-- Argumentos: user_email text, new_role text
CREATE OR REPLACE FUNCTION public.update_user_role(user_email text, new_role text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    target_user_id UUID;
BEGIN
    -- Encontra o ID do usuário pelo email
    SELECT id INTO target_user_id
    FROM auth.users
    WHERE email = user_email;

    -- Se o usuário não for encontrado, retorna falso
    IF target_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Atualiza o papel do usuário
    UPDATE auth.users
    SET raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{role}',
        concat('"', new_role, '"')::jsonb
    )
    WHERE id = target_user_id;

    RETURN TRUE;
END;
$function$;
-- Funções trigger
-- Trigger: check_schedule_conflict
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.check_schedule_conflict()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_instructor_id UUID;
    v_conflict_exists BOOLEAN;
BEGIN
    -- Obter o ID do instrutor para a turma do novo evento.
    SELECT instructor_id INTO v_instructor_id
    FROM public.classes
    WHERE id = NEW.class_id;

    -- Se não houver um instrutor para a turma, não há conflito a verificar.
    IF v_instructor_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Verificar se existe algum outro evento para o mesmo instrutor
    -- que se sobreponha no tempo com o novo evento.
    -- O operador OVERLAPS é ideal para isso.
    -- Excluímos o próprio evento (em caso de UPDATE) da verificação.
    SELECT EXISTS (
        SELECT 1
        FROM public.calendar_events ce
        JOIN public.classes c ON ce.class_id = c.id
        WHERE c.instructor_id = v_instructor_id
        AND (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND ce.id <> NEW.id)) -- Exclui o próprio evento se for um update
        AND (ce.start_time, ce.end_time) OVERLAPS (NEW.start_time, NEW.end_time)
    ) INTO v_conflict_exists;

    -- Se um conflito for encontrado, levanta uma exceção.
    IF v_conflict_exists THEN
        RAISE EXCEPTION 'Conflito de agendamento: O professor já está ocupado neste horário.';
    END IF;

    -- Se não houver conflito, permite que a operação continue.
    RETURN NEW;
END;
$function$;
-- Trigger: create_ticket_status_change_notification
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.create_ticket_status_change_notification()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Verifica se o status foi realmente alterado
  IF NEW.status IS DISTINCT FROM OLD.status THEN
    -- Insere uma notificação para o usuário que abriu o ticket
    INSERT INTO public.notifications (user_id, message, type, link)
    VALUES (
      NEW.user_id,
      'O status do seu ticket "' || NEW.subject || '" foi atualizado para: ' || NEW.status,
      'ticket_status_update',
      '/admin/requests?request_id=' || NEW.id -- O link pode apontar para a página de detalhes do ticket
    );
  END IF;
  RETURN NEW;
END;
$function$;
-- Trigger: ensure_user_profile
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.ensure_user_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- Verificar se o perfil já existe
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
        -- Criar perfil automaticamente
        INSERT INTO public.profiles (id, email, name, role)
        VALUES (
            auth.uid(),
            COALESCE(
                (SELECT email FROM auth.users WHERE id = auth.uid()),
                'user@example.com'
            ),
            COALESCE(
                (SELECT raw_user_meta_data->>'full_name' FROM auth.users WHERE id = auth.uid()),
                'Usuário'
            ),
            'student' -- Role padrão
        );
    END IF;
    
    RETURN NEW;
END;
$function$;
-- Trigger: handle_new_user
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    INSERT INTO public.profiles (id, name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
    );
    RETURN NEW;
END;
$function$;
-- Trigger: handle_professor_details_update
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.handle_professor_details_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$;
-- Trigger: log_completed_class_hours
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.log_completed_class_hours()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_instructor_id UUID;
    v_course_id UUID;
    v_duration_hours NUMERIC;
BEGIN
    -- Only run the logic if the status is updated to 'completed'
    IF TG_OP = 'UPDATE' AND NEW.status = 'completed' AND OLD.status <> 'completed' THEN
        -- Get instructor_id and course_id from the class
        SELECT instructor_id, course_id INTO v_instructor_id, v_course_id
        FROM public.classes
        WHERE id = NEW.class_id;

        -- If there's an instructor, proceed
        IF v_instructor_id IS NOT NULL AND v_course_id IS NOT NULL THEN
            -- Calculate the duration of the event in hours
            v_duration_hours := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time)) / 3600.0;

            -- Upsert the hours_logged in the courses_taught table
            INSERT INTO public.courses_taught (professor_id, course_id, hours_logged)
            VALUES (v_instructor_id, v_course_id, v_duration_hours)
            ON CONFLICT (professor_id, course_id)
            DO UPDATE SET hours_logged = courses_taught.hours_logged + v_duration_hours;
        END IF;
    END IF;

    RETURN NEW;
END;
$function$;
-- Trigger: moddatetime
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.moddatetime()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$;
-- Trigger: sync_profile_from_auth
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.sync_profile_from_auth()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE public.profiles
  SET name = COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
      email = NEW.email,
      role = COALESCE(NEW.raw_user_meta_data->>'role', 'student'),
      updated_at = now()
  WHERE id = NEW.id;
  RETURN NEW;
END;
$function$;
-- Trigger: trigger_set_timestamp
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.trigger_set_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$;
-- Trigger: update_marketing_timestamp
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.update_marketing_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$function$;
-- Trigger: update_updated_at_column
-- Retorna: trigger
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$;


