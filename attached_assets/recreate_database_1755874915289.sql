-- Script SQL para recriar todas as tabelas do banco de dados
-- Gerado automaticamente a partir do arquivo JSON

-- Habilitar extensão UUID se necessário
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Dropar tabelas existentes (cuidado com foreign keys)
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS submission_answers CASCADE;
DROP TABLE IF EXISTS service_providers CASCADE;
DROP TABLE IF EXISTS service_price_list CASCADE;
DROP TABLE IF EXISTS scholarships CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS retention_actions CASCADE;
DROP TABLE IF EXISTS request_comments CASCADE;
DROP TABLE IF EXISTS quizzes CASCADE;
DROP TABLE IF EXISTS quiz_responses CASCADE;
DROP TABLE IF EXISTS quiz_attempts CASCADE;
DROP TABLE IF EXISTS quiz_attempt_answers CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS profile_scholarships CASCADE;
DROP TABLE IF EXISTS professor_payments CASCADE;
DROP TABLE IF EXISTS professor_details CASCADE;
DROP TABLE IF EXISTS price_tables CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS newsletter_templates CASCADE;
DROP TABLE IF EXISTS modules CASCADE;
DROP TABLE IF EXISTS module_prerequisites CASCADE;
DROP TABLE IF EXISTS members CASCADE;
DROP TABLE IF EXISTS marketing_campaigns CASCADE;
DROP TABLE IF EXISTS low_attendance_alerts CASCADE;
DROP TABLE IF EXISTS lessons CASCADE;
DROP TABLE IF EXISTS lesson_progress CASCADE;
DROP TABLE IF EXISTS lesson_plans CASCADE;
DROP TABLE IF EXISTS lesson_attachments CASCADE;
DROP TABLE IF EXISTS leads CASCADE;
DROP TABLE IF EXISTS lead_interactions CASCADE;
DROP TABLE IF EXISTS general_documents CASCADE;
DROP TABLE IF EXISTS forum_messages CASCADE;
DROP TABLE IF EXISTS form_submissions CASCADE;
DROP TABLE IF EXISTS form_responses CASCADE;
DROP TABLE IF EXISTS form_fields CASCADE;
DROP TABLE IF EXISTS financial_transactions CASCADE;
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS email_tracking CASCADE;
DROP TABLE IF EXISTS email_templates CASCADE;
DROP TABLE IF EXISTS email_subscribers CASCADE;
DROP TABLE IF EXISTS email_settings CASCADE;
DROP TABLE IF EXISTS email_metrics CASCADE;
DROP TABLE IF EXISTS email_lists CASCADE;
DROP TABLE IF EXISTS email_list_contacts CASCADE;
DROP TABLE IF EXISTS email_campaigns CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS customer_segments CASCADE;
DROP TABLE IF EXISTS custom_forms CASCADE;
DROP TABLE IF EXISTS courses_taught CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS course_prerequisites CASCADE;
DROP TABLE IF EXISTS course_forums CASCADE;
DROP TABLE IF EXISTS course_duplications CASCADE;
DROP TABLE IF EXISTS course_documents CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS class_attendance CASCADE;
DROP TABLE IF EXISTS certificates CASCADE;
DROP TABLE IF EXISTS campaign_metrics CASCADE;
DROP TABLE IF EXISTS calendar_events CASCADE;
DROP TABLE IF EXISTS answers CASCADE;
DROP TABLE IF EXISTS announcements CASCADE;
DROP TABLE IF EXISTS administrative_requests CASCADE;
DROP TABLE IF EXISTS academic_works CASCADE;

-- Criar tabelas
-- Tabela: academic_works
CREATE TABLE academic_works (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    class_id UUID NOT NULL,
    user_id UUID NOT NULL,
    title TEXT NOT NULL,
    document_url TEXT NOT NULL,
    document_type TEXT,
    file_size BIGINT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: administrative_requests
CREATE TABLE administrative_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    request_type TEXT NOT NULL,
    subject TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL,
    assigned_to UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: announcements
CREATE TABLE announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    course_id UUID NOT NULL,
    class_id UUID,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: answers
CREATE TABLE answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    question_id UUID NOT NULL,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: calendar_events
CREATE TABLE calendar_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    class_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    room_id UUID,
    course_id UUID,
    module_id UUID,
    user_id UUID,
    status TEXT
);

-- Tabela: campaign_metrics
CREATE TABLE campaign_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    campaign_id UUID NOT NULL,
    metric_date DATE NOT NULL,
    impressions INTEGER,
    clicks INTEGER,
    conversions INTEGER,
    cost NUMERIC,
    leads_generated INTEGER,
    enrollments INTEGER,
    revenue NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: certificates
CREATE TABLE certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    course_id UUID NOT NULL,
    course_name TEXT NOT NULL,
    user_name TEXT NOT NULL,
    issue_date TIMESTAMP WITH TIME ZONE NOT NULL,
    expiry_date TIMESTAMP WITH TIME ZONE,
    certificate_url TEXT
);

-- Tabela: class_attendance
CREATE TABLE class_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    class_id UUID NOT NULL,
    user_id UUID NOT NULL,
    event_date DATE NOT NULL,
    status TEXT NOT NULL,
    notes TEXT,
    recorded_by UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: classes
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    course_id UUID NOT NULL,
    name TEXT NOT NULL,
    instructor_id UUID,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT
);

-- Tabela: contracts
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    provider_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    value NUMERIC,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    evaluation_score INTEGER,
    evaluation_comments TEXT,
    document_url TEXT,
    renewal_date TIMESTAMP WITH TIME ZONE
);

-- Tabela: course_documents
CREATE TABLE course_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    course_id UUID NOT NULL,
    document_name TEXT NOT NULL,
    document_url TEXT NOT NULL,
    file_type TEXT,
    file_size BIGINT,
    bucket_path TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: course_duplications
CREATE TABLE course_duplications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    original_course_id UUID NOT NULL,
    duplicated_course_id UUID NOT NULL,
    duplicated_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: course_forums
CREATE TABLE course_forums (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    course_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: course_prerequisites
CREATE TABLE course_prerequisites (
    course_id UUID NOT NULL,
    prerequisite_id UUID NOT NULL
);

-- Tabela: courses
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    thumbnail TEXT,
    duration TEXT,
    instructor TEXT NOT NULL,
    enrolledcount INTEGER,
    rating NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    professor_id UUID,
    status TEXT,
    expiry_date TIMESTAMP WITH TIME ZONE,
    approved_by UUID,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    category TEXT,
    has_evaluative_activity BOOLEAN,
    evaluative_activity_description TEXT,
    syllabus TEXT,
    bibliography TEXT,
    origin VARCHAR(255),
    nature VARCHAR(255)
);

-- Tabela: courses_taught
CREATE TABLE courses_taught (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    professor_id UUID NOT NULL,
    course_id UUID NOT NULL,
    hours_logged NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: custom_forms
CREATE TABLE custom_forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    course_id UUID NOT NULL,
    title TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: customer_segments
CREATE TABLE customer_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    criteria TEXT NOT NULL,
    is_active BOOLEAN,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: documents
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    document_type TEXT NOT NULL,
    title TEXT NOT NULL,
    content_html TEXT NOT NULL,
    issue_date TIMESTAMP WITH TIME ZONE NOT NULL,
    authentication_code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    course_id UUID,
    status TEXT NOT NULL
);

-- Tabela: email_campaigns
CREATE TABLE email_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    campaign_id UUID,
    template_id UUID,
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    sender_name VARCHAR(255) NOT NULL,
    sender_email VARCHAR(255) NOT NULL,
    status VARCHAR(50),
    scheduled_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    recipient_count INTEGER,
    delivered_count INTEGER,
    opened_count INTEGER,
    clicked_count INTEGER,
    bounced_count INTEGER,
    unsubscribed_count INTEGER,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: email_list_contacts
CREATE TABLE email_list_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    list_id UUID NOT NULL,
    email TEXT NOT NULL,
    name TEXT,
    lead_id UUID,
    user_id UUID,
    status TEXT,
    subscribed_at TIMESTAMP WITH TIME ZONE,
    unsubscribed_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: email_lists
CREATE TABLE email_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    subscriber_count INTEGER,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: email_metrics
CREATE TABLE email_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    email_log_id UUID,
    recipient_email TEXT NOT NULL,
    event_type TEXT NOT NULL,
    event_data TEXT,
    timestamp TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: email_settings
CREATE TABLE email_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    provider VARCHAR(50) NOT NULL,
    api_key TEXT,
    sender_domain VARCHAR(255),
    configuration TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: email_subscribers
CREATE TABLE email_subscribers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    list_id UUID,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    status VARCHAR(50),
    custom_fields TEXT,
    subscribed_at TIMESTAMP WITH TIME ZONE,
    unsubscribed_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: email_templates
CREATE TABLE email_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    subject TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT NOT NULL,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: email_tracking
CREATE TABLE email_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    campaign_id UUID NOT NULL,
    recipient_email TEXT NOT NULL,
    event_type TEXT NOT NULL,
    event_data TEXT,
    event_timestamp TIMESTAMP WITH TIME ZONE,
    user_agent TEXT,
    ip_address TEXT
);

-- Tabela: enrollments
CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    progress INTEGER,
    enrolled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    status TEXT,
    class_id UUID NOT NULL,
    course_id UUID
);

-- Tabela: financial_transactions
CREATE TABLE financial_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    type TEXT NOT NULL,
    status TEXT NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    paid_at TIMESTAMP WITH TIME ZONE,
    profile_id UUID,
    provider_id UUID,
    related_contract_id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: form_fields
CREATE TABLE form_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    form_id UUID NOT NULL,
    label TEXT NOT NULL,
    field_type TEXT NOT NULL,
    options TEXT,
    is_required BOOLEAN,
    order_number INTEGER NOT NULL
);

-- Tabela: form_responses
CREATE TABLE form_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    form_id UUID NOT NULL,
    user_id UUID NOT NULL,
    responses TEXT NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: form_submissions
CREATE TABLE form_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    form_id UUID NOT NULL,
    user_id UUID NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: forum_messages
CREATE TABLE forum_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    forum_id UUID NOT NULL,
    user_id UUID NOT NULL,
    message TEXT NOT NULL,
    parent_message_id UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: general_documents
CREATE TABLE general_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    document_url TEXT NOT NULL,
    document_type TEXT,
    category TEXT,
    file_size BIGINT,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT NOT NULL
);

-- Tabela: lead_interactions
CREATE TABLE lead_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    lead_id UUID NOT NULL,
    user_id UUID,
    interaction_type TEXT NOT NULL,
    subject TEXT NOT NULL,
    description TEXT,
    outcome TEXT,
    next_action TEXT,
    next_action_date TIMESTAMP WITH TIME ZONE,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: leads
CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    source TEXT,
    status TEXT NOT NULL,
    score INTEGER,
    company TEXT,
    position TEXT,
    notes TEXT,
    assigned_to UUID,
    conversion_date TIMESTAMP WITH TIME ZONE,
    converted_to_user_id UUID,
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,
    utm_content TEXT,
    utm_term TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: lesson_attachments
CREATE TABLE lesson_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    lesson_id UUID NOT NULL,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size BIGINT,
    uploaded_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: lesson_plans
CREATE TABLE lesson_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    lesson_id UUID NOT NULL,
    content TEXT NOT NULL,
    objectives TEXT,
    materials TEXT,
    activities TEXT,
    assessment TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: lesson_progress
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    lesson_id UUID NOT NULL,
    completed BOOLEAN,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: lessons
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    module_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    duration TEXT,
    video_url TEXT,
    content TEXT,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    complementary_files TEXT
);

-- Tabela: low_attendance_alerts
CREATE TABLE low_attendance_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    class_id UUID NOT NULL,
    attendance_rate NUMERIC NOT NULL,
    alert_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: marketing_campaigns
CREATE TABLE marketing_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    description TEXT,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    budget NUMERIC,
    target_audience TEXT,
    goals TEXT,
    status TEXT NOT NULL,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: members
CREATE TABLE members (
    user_id UUID NOT NULL,
    team_id UUID NOT NULL
);

-- Tabela: module_prerequisites
CREATE TABLE module_prerequisites (
    module_id UUID NOT NULL,
    prerequisite_module_id UUID NOT NULL
);

-- Tabela: modules
CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    course_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    has_quiz BOOLEAN,
    quiz_data TEXT,
    syllabus TEXT,
    bibliography TEXT
);

-- Tabela: newsletter_templates
CREATE TABLE newsletter_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    html_content TEXT NOT NULL,
    text_content TEXT,
    variables TEXT,
    category VARCHAR(100),
    is_active BOOLEAN,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN,
    type TEXT,
    link TEXT,
    created_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: price_tables
CREATE TABLE price_tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    provider_id UUID NOT NULL,
    service_name TEXT NOT NULL,
    price NUMERIC NOT NULL,
    unit TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: professor_details
CREATE TABLE professor_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    bio TEXT,
    specialization TEXT,
    qualifications TEXT,
    availability TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: professor_payments
CREATE TABLE professor_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    professor_id UUID NOT NULL,
    amount NUMERIC NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE,
    course_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: profile_scholarships
CREATE TABLE profile_scholarships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    profile_id UUID NOT NULL,
    scholarship_id UUID NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT,
    bio TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    job_title TEXT,
    company TEXT,
    location TEXT,
    website TEXT,
    email TEXT,
    role TEXT,
    cpf TEXT
);

-- Tabela: questions
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    quiz_id UUID NOT NULL,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: quiz_attempt_answers
CREATE TABLE quiz_attempt_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    quiz_attempt_id UUID NOT NULL,
    question_id UUID NOT NULL,
    answer_id UUID,
    answer_text_input TEXT,
    is_correct BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    document_url TEXT
);

-- Tabela: quiz_attempts
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    quiz_id UUID NOT NULL,
    user_id UUID NOT NULL,
    score NUMERIC,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: quiz_responses
CREATE TABLE quiz_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    module_id UUID NOT NULL,
    responses TEXT NOT NULL,
    score INTEGER,
    max_score INTEGER,
    completed_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: quizzes
CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    course_id UUID NOT NULL,
    title TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: request_comments
CREATE TABLE request_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    request_id UUID NOT NULL,
    user_id UUID NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: retention_actions
CREATE TABLE retention_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    user_id UUID NOT NULL,
    admin_id UUID NOT NULL,
    action_type TEXT NOT NULL,
    notes TEXT,
    action_date TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: rooms
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    location TEXT,
    capacity INTEGER,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: scholarships
CREATE TABLE scholarships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    discount_percentage NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela: service_price_list
CREATE TABLE service_price_list (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    provider_id UUID NOT NULL,
    service_name TEXT NOT NULL,
    price NUMERIC NOT NULL,
    unit TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Tabela: service_providers
CREATE TABLE service_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    name TEXT NOT NULL,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    service_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    service_category TEXT,
    service_subcategory TEXT,
    company_data TEXT,
    user_id UUID
);

-- Tabela: submission_answers
CREATE TABLE submission_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    submission_id UUID NOT NULL,
    field_id UUID NOT NULL,
    answer_text TEXT NOT NULL
);

-- Tabela: user_roles
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    role_name VARCHAR(255) NOT NULL,
    description TEXT
);
