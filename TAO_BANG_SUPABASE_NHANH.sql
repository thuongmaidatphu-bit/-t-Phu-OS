-- =========================================================================
-- ĐẤT PHÚ ONEBASE — TẠO NHANH BẢNG CƠ SỞ DỮ LIỆU TRÊN SUPABASE CLOUD LIVE
-- Dự án: ckyydvyzucvcdunvedmg
-- Dán đoạn mã này vào Supabase -> SQL Editor -> Bấm RUN (Ctrl + Enter)
-- =========================================================================

-- 1. BẢNG ĐƠN HÀNG & LỆNH GỌI THỢ CỨU HỘ 15P (ORDERS)
CREATE TABLE IF NOT EXISTS public.orders (
  id TEXT PRIMARY KEY,
  customer_name TEXT,
  phone TEXT,
  address TEXT,
  amount NUMERIC DEFAULT 0,
  status TEXT DEFAULT 'dispatched_15p',
  items JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Phân quyền RLS: Cho phép khách hàng gửi đơn và tra cứu
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public Anon Insert Orders" ON public.orders;
CREATE POLICY "Public Anon Insert Orders" ON public.orders FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public Anon Select Orders" ON public.orders;
CREATE POLICY "Public Anon Select Orders" ON public.orders FOR SELECT USING (true);

-- 2. BẢNG ĐÁNH GIÁ THỢ 5 SAO (REVIEWS)
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id TEXT,
  worker_id TEXT,
  worker_name TEXT,
  rating NUMERIC DEFAULT 5,
  feedback_pills TEXT[],
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public Anon Insert Reviews" ON public.reviews;
CREATE POLICY "Public Anon Insert Reviews" ON public.reviews FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public Anon Select Reviews" ON public.reviews;
CREATE POLICY "Public Anon Select Reviews" ON public.reviews FOR SELECT USING (true);

-- 3. BẢNG KHIẾU NẠI & KHÓA VÍ 24H (DISPUTES)
CREATE TABLE IF NOT EXISTS public.disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id TEXT,
  phone TEXT,
  reason TEXT,
  description TEXT,
  status TEXT DEFAULT 'pending_lock_24h',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public Anon Insert Disputes" ON public.disputes;
CREATE POLICY "Public Anon Insert Disputes" ON public.disputes FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public Anon Select Disputes" ON public.disputes;
CREATE POLICY "Public Anon Select Disputes" ON public.disputes FOR SELECT USING (true);

-- Cấp toàn quyền truy cập Schema công khai
GRANT ALL ON TABLE public.orders TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.reviews TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.disputes TO anon, authenticated, service_role;
