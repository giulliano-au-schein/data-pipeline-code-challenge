-- =============================================================================
-- Marketplace Platform - Source Database Schema
-- Senior Data Engineer Exercise
-- =============================================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- USERS TABLE
-- Note: Contains both buyers and sellers (user_type field)
-- Challenge: Some users changed type over time (seller -> buyer)
-- =============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('buyer', 'seller', 'both')),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    country_code CHAR(2),
    -- Seller-specific fields (NULL for pure buyers)
    seller_tier VARCHAR(20) CHECK (seller_tier IN ('bronze', 'silver', 'gold', 'platinum')),
    seller_rating DECIMAL(3, 2),
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,  -- Soft delete
    is_active BOOLEAN DEFAULT true
);

CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_country ON users(country_code);
CREATE INDEX idx_users_created ON users(created_at);

-- =============================================================================
-- CATEGORIES TABLE
-- Hierarchical categories with parent-child relationships
-- =============================================================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    parent_id INTEGER REFERENCES categories(id),
    level INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_parent ON categories(parent_id);

-- =============================================================================
-- PRODUCTS TABLE
-- Challenge: price_currency varies by seller region
-- Challenge: Some products have future updated_at (late-arriving data)
-- =============================================================================
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES users(id),
    category_id INTEGER REFERENCES categories(id),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    price_amount DECIMAL(12, 2) NOT NULL,
    price_currency CHAR(3) NOT NULL DEFAULT 'USD',  -- ISO 4217
    quantity_available INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('draft', 'active', 'paused', 'sold_out', 'deleted')),
    -- Metadata
    tags TEXT[],  -- Array type - needs special handling
    attributes JSONB,  -- JSON - needs flattening
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_products_seller ON products(seller_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_created ON products(created_at);

-- =============================================================================
-- ORDERS TABLE
-- Challenge: Contains timezone-naive timestamps mixed with timezone-aware
-- =============================================================================
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) NOT NULL UNIQUE,  -- Human-readable: ORD-YYYYMMDD-XXXXX
    buyer_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    -- Amounts
    subtotal_amount DECIMAL(12, 2) NOT NULL,
    shipping_amount DECIMAL(12, 2) DEFAULT 0,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    discount_amount DECIMAL(12, 2) DEFAULT 0,
    total_amount DECIMAL(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    -- Shipping address (denormalized intentionally)
    shipping_country CHAR(2),
    shipping_city VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    -- Timestamps - GOTCHA: Some are timezone-naive!
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,  -- Intentionally without timezone
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_orders_buyer ON orders(buyer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);

-- =============================================================================
-- ORDER_ITEMS TABLE
-- Line items linking orders to products
-- =============================================================================
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id),
    product_id UUID NOT NULL REFERENCES products(id),
    seller_id UUID NOT NULL REFERENCES users(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12, 2) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    -- Snapshot of product at time of order
    product_title VARCHAR(500),
    product_snapshot JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_seller ON order_items(seller_id);

-- =============================================================================
-- PAYMENTS TABLE
-- Challenge: Contains duplicate events (same payment_id, different timestamps)
-- =============================================================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id),
    payment_provider VARCHAR(50) NOT NULL,  -- stripe, paypal, etc.
    payment_provider_id VARCHAR(100),  -- External ID
    amount DECIMAL(12, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    platform_fee DECIMAL(12, 2) DEFAULT 0,  -- Marketplace cut
    seller_payout DECIMAL(12, 2),
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'disputed')),
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,
    -- Event tracking for idempotency challenge
    event_id VARCHAR(100),  -- Duplicate events will have same event_id
    event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_event ON payments(event_id);

-- =============================================================================
-- REVIEWS TABLE
-- Product reviews with ratings
-- =============================================================================
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(id),
    order_item_id UUID REFERENCES order_items(id),
    reviewer_id UUID NOT NULL REFERENCES users(id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    body TEXT,
    is_verified_purchase BOOLEAN DEFAULT false,
    helpful_votes INTEGER DEFAULT 0,
    -- Moderation
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'flagged')),
    moderated_at TIMESTAMP WITH TIME ZONE,
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_reviewer ON reviews(reviewer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- =============================================================================
-- SELLER_TIER_HISTORY TABLE (SCD Type 2)
-- Tracks seller tier changes over time
-- Challenge: Requires SCD Type 2 modeling in dbt
-- =============================================================================
CREATE TABLE seller_tier_history (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    tier VARCHAR(20) NOT NULL,
    effective_from TIMESTAMP WITH TIME ZONE NOT NULL,
    effective_to TIMESTAMP WITH TIME ZONE,  -- NULL = current
    is_current BOOLEAN DEFAULT true,
    change_reason VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_seller_tier_user ON seller_tier_history(user_id);
CREATE INDEX idx_seller_tier_current ON seller_tier_history(is_current) WHERE is_current = true;

-- =============================================================================
-- EVENT_LOG TABLE
-- Raw event stream for CDC simulation
-- Challenge: Events can arrive out of order
-- =============================================================================
CREATE TABLE event_log (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    event_data JSONB NOT NULL,
    event_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed BOOLEAN DEFAULT false
);

CREATE INDEX idx_event_log_type ON event_log(event_type);
CREATE INDEX idx_event_log_entity ON event_log(entity_type, entity_id);
CREATE INDEX idx_event_log_timestamp ON event_log(event_timestamp);
