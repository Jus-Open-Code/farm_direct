-- ==========================================
-- FARM DIRECT - SUPABASE POSTGRESQL SCHEMA
-- ==========================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table (Core references to Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    role TEXT CHECK (role IN ('farmer', 'buyer')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 2. Sequence and Trigger for FARMER ID Generation (e.g. FARM000001)
CREATE SEQUENCE IF NOT EXISTS public.farmer_id_seq START WITH 1;

CREATE OR REPLACE FUNCTION public.generate_farmer_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.farmer_id IS NULL THEN
        NEW.farmer_id := 'FARM' || LPAD(NEXTVAL('public.farmer_id_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Farmer Profiles Table
CREATE TABLE IF NOT EXISTS public.farmer_profiles (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    farmer_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    village TEXT NOT NULL,
    district TEXT NOT NULL,
    state TEXT NOT NULL,
    pincode TEXT NOT NULL,
    farm_size NUMERIC NOT NULL,
    products TEXT[] DEFAULT '{}',
    profile_photo TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Attach trigger for farmer_id generation
CREATE OR REPLACE TRIGGER trigger_generate_farmer_id
BEFORE INSERT ON public.farmer_profiles
FOR EACH ROW
EXECUTE FUNCTION public.generate_farmer_id();

ALTER TABLE public.farmer_profiles ENABLE ROW LEVEL SECURITY;

-- 4. Buyer Profiles Table
CREATE TABLE IF NOT EXISTS public.buyer_profiles (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    address TEXT,
    profile_photo TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.buyer_profiles ENABLE ROW LEVEL SECURITY;

-- 5. Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES public.farmer_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('Vegetables', 'Fruits', 'Grains', 'Pulses', 'Organic', 'Spices', 'Other')),
    quantity NUMERIC NOT NULL CHECK (quantity >= 0),
    unit TEXT NOT NULL CHECK (unit IN ('kg', 'quintal', 'ton', 'piece', 'dozen', 'litre')),
    price NUMERIC NOT NULL CHECK (price >= 0),
    description TEXT,
    image_url TEXT,
    harvest_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- 6. Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL REFERENCES public.buyer_profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- 7. Order Items Table
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    price NUMERIC NOT NULL CHECK (price >= 0)
);

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- 8. Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL CHECK (amount >= 0),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    payment_method TEXT NOT NULL,
    transaction_id TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- 9. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 10. Market Rates Table (Dynamic & Queryable)
CREATE TABLE IF NOT EXISTS public.market_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_name TEXT NOT NULL,
    state TEXT NOT NULL,
    district TEXT NOT NULL,
    min_price NUMERIC NOT NULL CHECK (min_price >= 0),
    max_price NUMERIC NOT NULL CHECK (max_price >= 0),
    modal_price NUMERIC NOT NULL CHECK (modal_price >= 0),
    date DATE NOT NULL DEFAULT CURRENT_DATE
);

ALTER TABLE public.market_rates ENABLE ROW LEVEL SECURITY;

-- 12. Reviews Table
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    buyer_id UUID NOT NULL REFERENCES public.buyer_profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- 13. Wishlist Table
CREATE TABLE IF NOT EXISTS public.wishlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL REFERENCES public.buyer_profiles(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(buyer_id, product_id)
);

ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;

-- 14. Cart Table
CREATE TABLE IF NOT EXISTS public.cart (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL REFERENCES public.buyer_profiles(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(buyer_id, product_id)
);

ALTER TABLE public.cart ENABLE ROW LEVEL SECURITY;

-- 15. Addresses Table
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL REFERENCES public.buyer_profiles(id) ON DELETE CASCADE,
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    pincode TEXT NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;

-- 16. Messages Table (Realtime Chat Support)
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;


-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Users Policies
CREATE POLICY "Users can view their own record" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own record" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Farmer Profiles Policies
CREATE POLICY "Anyone can view farmer profiles" ON public.farmer_profiles FOR SELECT USING (true);
CREATE POLICY "Farmers can edit their own profile" ON public.farmer_profiles FOR ALL USING (auth.uid() = id);

-- Buyer Profiles Policies
CREATE POLICY "Anyone can view buyer profiles" ON public.buyer_profiles FOR SELECT USING (true);
CREATE POLICY "Buyers can edit their own profile" ON public.buyer_profiles FOR ALL USING (auth.uid() = id);

-- Products Policies
CREATE POLICY "Anyone can view products" ON public.products FOR SELECT USING (true);
CREATE POLICY "Farmers can manage their products" ON public.products FOR ALL USING (
    auth.uid() = farmer_id
);

-- Orders Policies
CREATE POLICY "Buyers can view/create their own orders" ON public.orders FOR ALL USING (
    auth.uid() = buyer_id
);
CREATE POLICY "Farmers can view orders for their products" ON public.orders FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.order_items oi
        JOIN public.products p ON oi.product_id = p.id
        WHERE oi.order_id = orders.id AND p.farmer_id = auth.uid()
    )
);

-- Order Items Policies
CREATE POLICY "Buyers can manage items in their orders" ON public.order_items FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = order_items.order_id AND o.buyer_id = auth.uid()
    )
);
CREATE POLICY "Farmers can view order items for their products" ON public.order_items FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.products p
        WHERE p.id = order_items.product_id AND p.farmer_id = auth.uid()
    )
);

-- Payments Policies
CREATE POLICY "Users can manage their own payments" ON public.payments FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = payments.order_id AND o.buyer_id = auth.uid()
    )
);

-- Notifications Policies
CREATE POLICY "Users can view/update their own notifications" ON public.notifications FOR ALL USING (
    auth.uid() = user_id
);

-- Market Rates Policies
CREATE POLICY "Anyone can view market rates" ON public.market_rates FOR SELECT USING (true);

-- Reviews Policies
CREATE POLICY "Anyone can view reviews" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Buyers can manage their reviews" ON public.reviews FOR ALL USING (
    auth.uid() = buyer_id
);

-- Wishlist Policies
CREATE POLICY "Buyers can manage their wishlist" ON public.wishlist FOR ALL USING (
    auth.uid() = buyer_id
);

-- Cart Policies
CREATE POLICY "Buyers can manage their cart" ON public.cart FOR ALL USING (
    auth.uid() = buyer_id
);

-- Addresses Policies
CREATE POLICY "Buyers can manage their addresses" ON public.addresses FOR ALL USING (
    auth.uid() = buyer_id
);

-- Messages Policies
CREATE POLICY "Users can view messages they sent or received" ON public.messages FOR SELECT USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
);
CREATE POLICY "Users can send messages" ON public.messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id
);


-- ==========================================
-- AUTOMATIC SYNC FROM AUTH TO PUBLIC USERS
-- ==========================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, role)
    VALUES (NEW.id, NEW.email, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Seed some default market rates
INSERT INTO public.market_rates (crop_name, state, district, min_price, max_price, modal_price, date)
VALUES
('Tomato', 'Maharashtra', 'Pune', 15.00, 25.00, 20.00, CURRENT_DATE),
('Potato', 'Uttar Pradesh', 'Agra', 12.00, 18.00, 15.00, CURRENT_DATE),
('Onion', 'Maharashtra', 'Nashik', 20.00, 35.00, 28.00, CURRENT_DATE),
('Wheat', 'Punjab', 'Ludhiana', 22.00, 26.00, 24.50, CURRENT_DATE),
('Rice', 'West Bengal', 'Bardhaman', 28.00, 38.00, 33.00, CURRENT_DATE),
('Apple', 'Himachal Pradesh', 'Shimla', 80.00, 150.00, 110.00, CURRENT_DATE)
ON CONFLICT DO NOTHING;
