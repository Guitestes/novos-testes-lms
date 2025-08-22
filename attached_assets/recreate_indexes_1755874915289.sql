-- Script SQL para recriar índices
-- Gerado automaticamente a partir de index.json
-- Data: 2025-08-22T12:41:11.313Z

-- Remover todos os índices secundários existentes
DROP INDEX IF EXISTS "campaign_metrics_campaign_id_metric_date_key";
DROP INDEX IF EXISTS "idx_campaign_metrics_campaign_id";
DROP INDEX IF EXISTS "idx_campaign_metrics_metric_date";
DROP INDEX IF EXISTS "class_attendance_class_id_user_id_event_date_key";
DROP INDEX IF EXISTS "courses_taught_professor_id_course_id_key";
DROP INDEX IF EXISTS "custom_forms_course_id_key";
DROP INDEX IF EXISTS "documents_authentication_code_key";
DROP INDEX IF EXISTS "idx_documents_authentication_code";
DROP INDEX IF EXISTS "idx_documents_document_type";
DROP INDEX IF EXISTS "idx_documents_user_id";
DROP INDEX IF EXISTS "email_list_contacts_list_id_email_key";
DROP INDEX IF EXISTS "idx_email_lists_created_by";
DROP INDEX IF EXISTS "idx_email_metrics_email_log_id";
DROP INDEX IF EXISTS "idx_email_metrics_event_type";
DROP INDEX IF EXISTS "idx_email_metrics_recipient_email";
DROP INDEX IF EXISTS "idx_email_metrics_timestamp";
DROP INDEX IF EXISTS "email_subscribers_list_id_email_key";
DROP INDEX IF EXISTS "idx_email_subscribers_list_email";
DROP INDEX IF EXISTS "idx_email_subscribers_status";
DROP INDEX IF EXISTS "idx_email_templates_created_by";
DROP INDEX IF EXISTS "idx_email_templates_type";
DROP INDEX IF EXISTS "idx_email_tracking_campaign_id";
DROP INDEX IF EXISTS "idx_email_tracking_event_type";
DROP INDEX IF EXISTS "enrollments_user_id_class_id_key";
DROP INDEX IF EXISTS "form_submissions_form_id_user_id_key";
DROP INDEX IF EXISTS "idx_lead_interactions_created_at";
DROP INDEX IF EXISTS "idx_lead_interactions_created_by";
DROP INDEX IF EXISTS "idx_lead_interactions_lead_id";
DROP INDEX IF EXISTS "idx_leads_assigned_to";
DROP INDEX IF EXISTS "idx_leads_created_at";
DROP INDEX IF EXISTS "idx_leads_email";
DROP INDEX IF EXISTS "idx_leads_source";
DROP INDEX IF EXISTS "idx_leads_status";
DROP INDEX IF EXISTS "unique_alert_per_day";
DROP INDEX IF EXISTS "idx_marketing_campaigns_created_by";
DROP INDEX IF EXISTS "idx_marketing_campaigns_start_date";
DROP INDEX IF EXISTS "idx_marketing_campaigns_status";
DROP INDEX IF EXISTS "idx_marketing_campaigns_type";
DROP INDEX IF EXISTS "profile_scholarships_profile_id_scholarship_id_key";
DROP INDEX IF EXISTS "unique_cpf";
DROP INDEX IF EXISTS "quiz_attempts_quiz_id_user_id_key";
DROP INDEX IF EXISTS "service_providers_email_key";
DROP INDEX IF EXISTS "user_roles_role_name_key";

-- Índices para tabela: academic_works
-- Chaves primárias (criadas automaticamente com a tabela):
-- academic_works_pkey


-- Índices para tabela: administrative_requests
-- Chaves primárias (criadas automaticamente com a tabela):
-- administrative_requests_pkey


-- Índices para tabela: announcements
-- Chaves primárias (criadas automaticamente com a tabela):
-- announcements_pkey


-- Índices para tabela: answers
-- Chaves primárias (criadas automaticamente com a tabela):
-- answers_pkey


-- Índices para tabela: calendar_events
-- Chaves primárias (criadas automaticamente com a tabela):
-- calendar_events_pkey


-- Índices para tabela: campaign_metrics
-- Chaves primárias (criadas automaticamente com a tabela):
-- campaign_metrics_pkey

-- Índices secundários:
CREATE UNIQUE INDEX campaign_metrics_campaign_id_metric_date_key ON public.campaign_metrics USING btree (campaign_id, metric_date);
CREATE INDEX idx_campaign_metrics_campaign_id ON public.campaign_metrics USING btree (campaign_id);
CREATE INDEX idx_campaign_metrics_metric_date ON public.campaign_metrics USING btree (metric_date);

-- Índices para tabela: certificates
-- Chaves primárias (criadas automaticamente com a tabela):
-- certificates_pkey


-- Índices para tabela: class_attendance
-- Chaves primárias (criadas automaticamente com a tabela):
-- class_attendance_pkey

-- Índices secundários:
CREATE UNIQUE INDEX class_attendance_class_id_user_id_event_date_key ON public.class_attendance USING btree (class_id, user_id, event_date);

-- Índices para tabela: classes
-- Chaves primárias (criadas automaticamente com a tabela):
-- classes_pkey


-- Índices para tabela: contracts
-- Chaves primárias (criadas automaticamente com a tabela):
-- contracts_pkey


-- Índices para tabela: course_documents
-- Chaves primárias (criadas automaticamente com a tabela):
-- course_documents_pkey


-- Índices para tabela: course_duplications
-- Chaves primárias (criadas automaticamente com a tabela):
-- course_duplications_pkey


-- Índices para tabela: course_forums
-- Chaves primárias (criadas automaticamente com a tabela):
-- course_forums_pkey


-- Índices para tabela: course_prerequisites
-- Chaves primárias (criadas automaticamente com a tabela):
-- course_prerequisites_pkey


-- Índices para tabela: courses
-- Chaves primárias (criadas automaticamente com a tabela):
-- courses_pkey


-- Índices para tabela: courses_taught
-- Chaves primárias (criadas automaticamente com a tabela):
-- courses_taught_pkey

-- Índices secundários:
CREATE UNIQUE INDEX courses_taught_professor_id_course_id_key ON public.courses_taught USING btree (professor_id, course_id);

-- Índices para tabela: custom_forms
-- Chaves primárias (criadas automaticamente com a tabela):
-- custom_forms_pkey

-- Índices secundários:
CREATE UNIQUE INDEX custom_forms_course_id_key ON public.custom_forms USING btree (course_id);

-- Índices para tabela: customer_segments
-- Chaves primárias (criadas automaticamente com a tabela):
-- customer_segments_pkey


-- Índices para tabela: documents
-- Chaves primárias (criadas automaticamente com a tabela):
-- documents_pkey

-- Índices secundários:
CREATE UNIQUE INDEX documents_authentication_code_key ON public.documents USING btree (authentication_code);
CREATE INDEX idx_documents_authentication_code ON public.documents USING btree (authentication_code);
CREATE INDEX idx_documents_document_type ON public.documents USING btree (document_type);
CREATE INDEX idx_documents_user_id ON public.documents USING btree (user_id);

-- Índices para tabela: email_campaigns
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_campaigns_pkey


-- Índices para tabela: email_list_contacts
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_list_contacts_pkey

-- Índices secundários:
CREATE UNIQUE INDEX email_list_contacts_list_id_email_key ON public.email_list_contacts USING btree (list_id, email);

-- Índices para tabela: email_lists
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_lists_pkey

-- Índices secundários:
CREATE INDEX idx_email_lists_created_by ON public.email_lists USING btree (created_by);

-- Índices para tabela: email_metrics
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_metrics_pkey

-- Índices secundários:
CREATE INDEX idx_email_metrics_email_log_id ON public.email_metrics USING btree (email_log_id);
CREATE INDEX idx_email_metrics_event_type ON public.email_metrics USING btree (event_type);
CREATE INDEX idx_email_metrics_recipient_email ON public.email_metrics USING btree (recipient_email);
CREATE INDEX idx_email_metrics_timestamp ON public.email_metrics USING btree ("timestamp");

-- Índices para tabela: email_settings
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_settings_pkey


-- Índices para tabela: email_subscribers
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_subscribers_pkey

-- Índices secundários:
CREATE UNIQUE INDEX email_subscribers_list_id_email_key ON public.email_subscribers USING btree (list_id, email);
CREATE INDEX idx_email_subscribers_list_email ON public.email_subscribers USING btree (list_id, email);
CREATE INDEX idx_email_subscribers_status ON public.email_subscribers USING btree (status);

-- Índices para tabela: email_templates
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_templates_pkey

-- Índices secundários:
CREATE INDEX idx_email_templates_created_by ON public.email_templates USING btree (created_by);
CREATE INDEX idx_email_templates_type ON public.email_templates USING btree (type);

-- Índices para tabela: email_tracking
-- Chaves primárias (criadas automaticamente com a tabela):
-- email_tracking_pkey

-- Índices secundários:
CREATE INDEX idx_email_tracking_campaign_id ON public.email_tracking USING btree (campaign_id);
CREATE INDEX idx_email_tracking_event_type ON public.email_tracking USING btree (event_type);

-- Índices para tabela: enrollments
-- Chaves primárias (criadas automaticamente com a tabela):
-- enrollments_pkey

-- Índices secundários:
CREATE UNIQUE INDEX enrollments_user_id_class_id_key ON public.enrollments USING btree (user_id, class_id);

-- Índices para tabela: financial_transactions
-- Chaves primárias (criadas automaticamente com a tabela):
-- financial_transactions_pkey


-- Índices para tabela: form_fields
-- Chaves primárias (criadas automaticamente com a tabela):
-- form_fields_pkey


-- Índices para tabela: form_responses
-- Chaves primárias (criadas automaticamente com a tabela):
-- form_responses_pkey


-- Índices para tabela: form_submissions
-- Chaves primárias (criadas automaticamente com a tabela):
-- form_submissions_pkey

-- Índices secundários:
CREATE UNIQUE INDEX form_submissions_form_id_user_id_key ON public.form_submissions USING btree (form_id, user_id);

-- Índices para tabela: forum_messages
-- Chaves primárias (criadas automaticamente com a tabela):
-- forum_messages_pkey


-- Índices para tabela: general_documents
-- Chaves primárias (criadas automaticamente com a tabela):
-- general_documents_pkey


-- Índices para tabela: lead_interactions
-- Chaves primárias (criadas automaticamente com a tabela):
-- lead_interactions_pkey

-- Índices secundários:
CREATE INDEX idx_lead_interactions_created_at ON public.lead_interactions USING btree (created_at);
CREATE INDEX idx_lead_interactions_created_by ON public.lead_interactions USING btree (created_by);
CREATE INDEX idx_lead_interactions_lead_id ON public.lead_interactions USING btree (lead_id);

-- Índices para tabela: leads
-- Chaves primárias (criadas automaticamente com a tabela):
-- leads_pkey

-- Índices secundários:
CREATE INDEX idx_leads_assigned_to ON public.leads USING btree (assigned_to);
CREATE INDEX idx_leads_created_at ON public.leads USING btree (created_at);
CREATE INDEX idx_leads_email ON public.leads USING btree (email);
CREATE INDEX idx_leads_source ON public.leads USING btree (source);
CREATE INDEX idx_leads_status ON public.leads USING btree (status);

-- Índices para tabela: lesson_attachments
-- Chaves primárias (criadas automaticamente com a tabela):
-- lesson_attachments_pkey


-- Índices para tabela: lesson_plans
-- Chaves primárias (criadas automaticamente com a tabela):
-- lesson_plans_pkey


-- Índices para tabela: lesson_progress
-- Chaves primárias (criadas automaticamente com a tabela):
-- lesson_progress_pkey


-- Índices para tabela: lessons
-- Chaves primárias (criadas automaticamente com a tabela):
-- lessons_pkey


-- Índices para tabela: low_attendance_alerts
-- Chaves primárias (criadas automaticamente com a tabela):
-- low_attendance_alerts_pkey

-- Índices secundários:
CREATE UNIQUE INDEX unique_alert_per_day ON public.low_attendance_alerts USING btree (user_id, class_id, alert_date);

-- Índices para tabela: marketing_campaigns
-- Chaves primárias (criadas automaticamente com a tabela):
-- marketing_campaigns_pkey

-- Índices secundários:
CREATE INDEX idx_marketing_campaigns_created_by ON public.marketing_campaigns USING btree (created_by);
CREATE INDEX idx_marketing_campaigns_start_date ON public.marketing_campaigns USING btree (start_date);
CREATE INDEX idx_marketing_campaigns_status ON public.marketing_campaigns USING btree (status);
CREATE INDEX idx_marketing_campaigns_type ON public.marketing_campaigns USING btree (type);

-- Índices para tabela: members
-- Chaves primárias (criadas automaticamente com a tabela):
-- members_pkey


-- Índices para tabela: module_prerequisites
-- Chaves primárias (criadas automaticamente com a tabela):
-- module_prerequisites_pkey


-- Índices para tabela: modules
-- Chaves primárias (criadas automaticamente com a tabela):
-- modules_pkey


-- Índices para tabela: newsletter_templates
-- Chaves primárias (criadas automaticamente com a tabela):
-- newsletter_templates_pkey


-- Índices para tabela: notifications
-- Chaves primárias (criadas automaticamente com a tabela):
-- notifications_pkey


-- Índices para tabela: price_tables
-- Chaves primárias (criadas automaticamente com a tabela):
-- price_tables_pkey


-- Índices para tabela: professor_details
-- Chaves primárias (criadas automaticamente com a tabela):
-- professor_details_pkey


-- Índices para tabela: professor_payments
-- Chaves primárias (criadas automaticamente com a tabela):
-- professor_payments_pkey


-- Índices para tabela: profile_scholarships
-- Chaves primárias (criadas automaticamente com a tabela):
-- profile_scholarships_pkey

-- Índices secundários:
CREATE UNIQUE INDEX profile_scholarships_profile_id_scholarship_id_key ON public.profile_scholarships USING btree (profile_id, scholarship_id);

-- Índices para tabela: profiles
-- Chaves primárias (criadas automaticamente com a tabela):
-- profiles_pkey

-- Índices secundários:
CREATE UNIQUE INDEX unique_cpf ON public.profiles USING btree (cpf);

-- Índices para tabela: questions
-- Chaves primárias (criadas automaticamente com a tabela):
-- questions_pkey


-- Índices para tabela: quiz_attempt_answers
-- Chaves primárias (criadas automaticamente com a tabela):
-- quiz_attempt_answers_pkey


-- Índices para tabela: quiz_attempts
-- Chaves primárias (criadas automaticamente com a tabela):
-- quiz_attempts_pkey

-- Índices secundários:
CREATE UNIQUE INDEX quiz_attempts_quiz_id_user_id_key ON public.quiz_attempts USING btree (quiz_id, user_id);

-- Índices para tabela: quiz_responses
-- Chaves primárias (criadas automaticamente com a tabela):
-- quiz_responses_pkey


-- Índices para tabela: quizzes
-- Chaves primárias (criadas automaticamente com a tabela):
-- quizzes_pkey


-- Índices para tabela: request_comments
-- Chaves primárias (criadas automaticamente com a tabela):
-- request_comments_pkey


-- Índices para tabela: retention_actions
-- Chaves primárias (criadas automaticamente com a tabela):
-- retention_actions_pkey


-- Índices para tabela: rooms
-- Chaves primárias (criadas automaticamente com a tabela):
-- rooms_pkey


-- Índices para tabela: scholarships
-- Chaves primárias (criadas automaticamente com a tabela):
-- scholarships_pkey


-- Índices para tabela: service_price_list
-- Chaves primárias (criadas automaticamente com a tabela):
-- service_price_list_pkey


-- Índices para tabela: service_providers
-- Chaves primárias (criadas automaticamente com a tabela):
-- service_providers_pkey

-- Índices secundários:
CREATE UNIQUE INDEX service_providers_email_key ON public.service_providers USING btree (email);

-- Índices para tabela: submission_answers
-- Chaves primárias (criadas automaticamente com a tabela):
-- submission_answers_pkey


-- Índices para tabela: user_roles
-- Chaves primárias (criadas automaticamente com a tabela):
-- user_roles_pkey

-- Índices secundários:
CREATE UNIQUE INDEX user_roles_role_name_key ON public.user_roles USING btree (role_name);

