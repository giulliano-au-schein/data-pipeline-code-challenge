-- =============================================================================
-- Marketplace Platform - Seed Data
-- Contains intentional data quality challenges for senior engineer assessment
-- =============================================================================

-- =============================================================================
-- CATEGORIES (Hierarchical)
-- =============================================================================
INSERT INTO categories (id, name, slug, parent_id, level) VALUES
(1, 'Electronics', 'electronics', NULL, 1),
(2, 'Smartphones', 'smartphones', 1, 2),
(3, 'Laptops', 'laptops', 1, 2),
(4, 'Audio', 'audio', 1, 2),
(5, 'Fashion', 'fashion', NULL, 1),
(6, 'Men''s Clothing', 'mens-clothing', 5, 2),
(7, 'Women''s Clothing', 'womens-clothing', 5, 2),
(8, 'Home & Garden', 'home-garden', NULL, 1),
(9, 'Furniture', 'furniture', 8, 2),
(10, 'Kitchen', 'kitchen', 8, 2),
(11, 'Sports', 'sports', NULL, 1),
(12, 'Collectibles', 'collectibles', NULL, 1);

SELECT setval('categories_id_seq', 12);

-- =============================================================================
-- USERS (Mix of buyers, sellers, and both)
-- Challenge: Some emails look similar (typos), seller_tier NULL for buyers
-- =============================================================================
INSERT INTO users (id, email, username, user_type, first_name, last_name, country_code, seller_tier, seller_rating, created_at, updated_at, is_active) VALUES
-- Sellers
('a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 'techstore@example.com', 'TechStorePro', 'seller', 'Michael', 'Chen', 'US', 'gold', 4.85, '2023-01-15 10:00:00+00', '2024-06-15 14:30:00+00', true),
('b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 'fashionista_uk@example.com', 'FashionistaUK', 'seller', 'Emma', 'Williams', 'GB', 'platinum', 4.92, '2022-06-20 08:00:00+00', '2024-08-01 09:00:00+00', true),
('c3d4e5f6-a7b8-6c7d-0e9f-1a2b3c4d5e6f', 'homegoods_de@example.com', 'HomeGoodsDE', 'seller', 'Hans', 'Mueller', 'DE', 'silver', 4.45, '2023-03-10 12:00:00+00', '2024-07-20 16:00:00+00', true),
('d4e5f6a7-b8c9-7d8e-1f0a-2b3c4d5e6f7a', 'vintage_finds@example.com', 'VintageFinds', 'seller', 'Sophie', 'Martin', 'FR', 'bronze', 4.12, '2023-08-05 14:00:00+00', '2024-05-10 11:00:00+00', true),
('e5f6a7b8-c9d0-8e9f-2a1b-3c4d5e6f7a8b', 'sports_outlet@example.com', 'SportsOutlet', 'seller', 'Carlos', 'Rodriguez', 'ES', 'gold', 4.78, '2022-11-01 09:00:00+00', '2024-09-01 08:00:00+00', true),

-- Buyers
('f6a7b8c9-d0e1-9f0a-3b2c-4d5e6f7a8b9c', 'john.buyer@gmail.com', 'JohnB123', 'buyer', 'John', 'Smith', 'US', NULL, NULL, '2023-02-28 15:00:00+00', '2024-04-15 10:00:00+00', true),
('a7b8c9d0-e1f2-0a1b-4c3d-5e6f7a8b9c0d', 'jane.doe@yahoo.com', 'JaneD', 'buyer', 'Jane', 'Doe', 'CA', NULL, NULL, '2023-04-12 11:00:00+00', '2024-07-22 14:00:00+00', true),
('b8c9d0e1-f2a3-1b2c-5d4e-6f7a8b9c0d1e', 'marco.rossi@outlook.com', 'MarcoR', 'buyer', 'Marco', 'Rossi', 'IT', NULL, NULL, '2023-05-20 16:00:00+00', '2024-08-30 12:00:00+00', true),
('c9d0e1f2-a3b4-2c3d-6e5f-7a8b9c0d1e2f', 'yuki.tanaka@example.jp', 'YukiT', 'buyer', 'Yuki', 'Tanaka', 'JP', NULL, NULL, '2023-07-08 07:00:00+00', '2024-09-05 09:00:00+00', true),
('d0e1f2a3-b4c5-3d4e-7f6a-8b9c0d1e2f3a', 'alex.kumar@gmail.com', 'AlexK', 'buyer', 'Alex', 'Kumar', 'IN', NULL, NULL, '2023-09-15 13:00:00+00', '2024-06-18 15:00:00+00', true),

-- Both (sellers who also buy)
('e1f2a3b4-c5d6-4e5f-8a7b-9c0d1e2f3a4b', 'reseller_pro@example.com', 'ResellerPro', 'both', 'David', 'Kim', 'KR', 'silver', 4.55, '2022-09-01 10:00:00+00', '2024-08-25 11:00:00+00', true),

-- CHALLENGE: Soft-deleted user
('f2a3b4c5-d6e7-5f6a-9b8c-0d1e2f3a4b5c', 'deleted_seller@example.com', 'DeletedSeller', 'seller', 'Robert', 'Johnson', 'US', 'bronze', 3.80, '2022-04-01 08:00:00+00', '2024-01-15 09:00:00+00', false),

-- CHALLENGE: User with NULL country
('a3b4c5d6-e7f8-6a7b-0c9d-1e2f3a4b5c6d', 'mystery_buyer@example.com', 'MysteryBuyer', 'buyer', NULL, NULL, NULL, NULL, NULL, '2024-01-10 14:00:00+00', '2024-01-10 14:00:00+00', true);

-- Set deleted_at for soft-deleted user
UPDATE users SET deleted_at = '2024-01-15 09:00:00+00' WHERE id = 'f2a3b4c5-d6e7-5f6a-9b8c-0d1e2f3a4b5c';

-- =============================================================================
-- PRODUCTS
-- Challenge: Various currencies, JSONB attributes, array tags
-- Challenge: Some products have future updated_at (late-arriving data simulation)
-- =============================================================================
INSERT INTO products (id, seller_id, category_id, title, description, price_amount, price_currency, quantity_available, status, tags, attributes, created_at, updated_at, published_at) VALUES
-- Electronics
('11111111-1111-1111-1111-111111111111', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 2, 'iPhone 15 Pro Max 256GB', 'Latest Apple flagship smartphone', 1199.00, 'USD', 50, 'active', ARRAY['apple', 'smartphone', 'premium'], '{"color": "titanium", "storage": "256GB", "condition": "new"}', '2024-01-15 10:00:00+00', '2024-09-01 14:00:00+00', '2024-01-15 12:00:00+00'),
('22222222-2222-2222-2222-222222222222', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 3, 'MacBook Pro 14" M3 Pro', 'Professional laptop for creators', 1999.00, 'USD', 25, 'active', ARRAY['apple', 'laptop', 'professional'], '{"chip": "M3 Pro", "ram": "18GB", "storage": "512GB"}', '2024-02-01 09:00:00+00', '2024-08-15 11:00:00+00', '2024-02-01 10:00:00+00'),
('33333333-3333-3333-3333-333333333333', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 4, 'Sony WH-1000XM5 Headphones', 'Premium noise-cancelling headphones', 349.99, 'USD', 100, 'active', ARRAY['sony', 'headphones', 'wireless'], '{"color": "black", "battery_life": "30h"}', '2024-03-10 14:00:00+00', '2024-07-20 16:00:00+00', '2024-03-10 15:00:00+00'),

-- Fashion (UK seller - GBP)
('44444444-4444-4444-4444-444444444444', 'b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 6, 'Premium Wool Overcoat', 'Handcrafted British wool coat', 450.00, 'GBP', 30, 'active', ARRAY['coat', 'wool', 'premium', 'winter'], '{"size": ["S", "M", "L", "XL"], "material": "100% wool"}', '2024-01-20 08:00:00+00', '2024-06-01 09:00:00+00', '2024-01-20 09:00:00+00'),
('55555555-5555-5555-5555-555555555555', 'b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 7, 'Silk Evening Dress', 'Elegant silk dress for special occasions', 280.00, 'GBP', 15, 'active', ARRAY['dress', 'silk', 'evening', 'elegant'], '{"size": ["XS", "S", "M", "L"], "color": "midnight blue"}', '2024-04-05 10:00:00+00', '2024-08-10 14:00:00+00', '2024-04-05 11:00:00+00'),

-- Home & Garden (German seller - EUR)
('66666666-6666-6666-6666-666666666666', 'c3d4e5f6-a7b8-6c7d-0e9f-1a2b3c4d5e6f', 9, 'Scandinavian Oak Dining Table', 'Solid oak table seats 6', 890.00, 'EUR', 10, 'active', ARRAY['furniture', 'dining', 'oak', 'scandinavian'], '{"dimensions": "180x90x75cm", "seats": 6}', '2024-02-15 12:00:00+00', '2024-05-20 15:00:00+00', '2024-02-15 13:00:00+00'),
('77777777-7777-7777-7777-777777777777', 'c3d4e5f6-a7b8-6c7d-0e9f-1a2b3c4d5e6f', 10, 'Professional Chef Knife Set', '8-piece German steel knife set', 320.00, 'EUR', 40, 'active', ARRAY['kitchen', 'knives', 'professional', 'german-steel'], '{"pieces": 8, "material": "German steel", "includes_block": true}', '2024-03-01 09:00:00+00', '2024-07-15 11:00:00+00', '2024-03-01 10:00:00+00'),

-- Vintage (French seller - EUR)
('88888888-8888-8888-8888-888888888888', 'd4e5f6a7-b8c9-7d8e-1f0a-2b3c4d5e6f7a', 12, 'Vintage Rolex Submariner 1968', 'Authentic vintage Rolex watch', 15000.00, 'EUR', 1, 'active', ARRAY['watch', 'rolex', 'vintage', 'luxury', 'collectible'], '{"year": 1968, "condition": "excellent", "box_papers": false}', '2024-05-01 14:00:00+00', '2024-09-05 10:00:00+00', '2024-05-01 15:00:00+00'),

-- Sports (Spanish seller - EUR)
('99999999-9999-9999-9999-999999999999', 'e5f6a7b8-c9d0-8e9f-2a1b-3c4d5e6f7a8b', 11, 'Professional Football Boots', 'Top-tier football boots for pros', 250.00, 'EUR', 60, 'active', ARRAY['football', 'boots', 'professional', 'sports'], '{"size_range": "38-46", "surface": "FG", "brand": "premium"}', '2024-04-15 11:00:00+00', '2024-08-01 13:00:00+00', '2024-04-15 12:00:00+00'),

-- CHALLENGE: Product with FUTURE updated_at (late-arriving data)
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 2, 'Samsung Galaxy S24 Ultra', 'Latest Samsung flagship', 1299.00, 'USD', 35, 'active', ARRAY['samsung', 'smartphone', 'android'], '{"storage": "512GB", "color": "phantom black"}', '2024-06-01 10:00:00+00', '2025-02-15 10:00:00+00', '2024-06-01 11:00:00+00'),  -- Future updated_at!

-- CHALLENGE: Sold out product
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 7, 'Limited Edition Cashmere Scarf', 'Exclusive limited run', 180.00, 'GBP', 0, 'sold_out', ARRAY['scarf', 'cashmere', 'limited'], '{"edition": "2024 Winter Collection"}', '2024-03-20 08:00:00+00', '2024-07-01 09:00:00+00', '2024-03-20 09:00:00+00'),

-- CHALLENGE: Draft product (should be filtered in analytics)
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'e1f2a3b4-c5d6-4e5f-8a7b-9c0d1e2f3a4b', 1, 'Upcoming Product Draft', 'Not yet published', 99.99, 'USD', 100, 'draft', ARRAY['draft'], '{}', '2024-09-01 10:00:00+00', '2024-09-01 10:00:00+00', NULL);

-- =============================================================================
-- ORDERS
-- Challenge: Mixed timezone handling, various statuses
-- =============================================================================
INSERT INTO orders (id, order_number, buyer_id, status, subtotal_amount, shipping_amount, tax_amount, discount_amount, total_amount, currency, shipping_country, shipping_city, shipping_postal_code, created_at, updated_at, confirmed_at, shipped_at, delivered_at) VALUES
-- Completed orders
('ord11111-1111-1111-1111-111111111111', 'ORD-20240115-00001', 'f6a7b8c9-d0e1-9f0a-3b2c-4d5e6f7a8b9c', 'delivered', 1199.00, 15.00, 109.26, 0, 1323.26, 'USD', 'US', 'New York', '10001', '2024-01-15 14:00:00+00', '2024-01-25 10:00:00+00', '2024-01-15 14:30:00', '2024-01-18 09:00:00+00', '2024-01-22 14:00:00+00'),
('ord22222-2222-2222-2222-222222222222', 'ORD-20240220-00002', 'a7b8c9d0-e1f2-0a1b-4c3d-5e6f7a8b9c0d', 'delivered', 450.00, 25.00, 0, 50.00, 425.00, 'GBP', 'CA', 'Toronto', 'M5V 1J2', '2024-02-20 11:00:00+00', '2024-03-05 16:00:00+00', '2024-02-20 11:15:00', '2024-02-25 08:00:00+00', '2024-03-02 12:00:00+00'),
('ord33333-3333-3333-3333-333333333333', 'ORD-20240310-00003', 'b8c9d0e1-f2a3-1b2c-5d4e-6f7a8b9c0d1e', 'delivered', 890.00, 45.00, 187.95, 0, 1122.95, 'EUR', 'IT', 'Milan', '20121', '2024-03-10 09:00:00+00', '2024-03-25 14:00:00+00', '2024-03-10 09:20:00', '2024-03-15 10:00:00+00', '2024-03-22 11:00:00+00'),

-- In-progress orders
('ord44444-4444-4444-4444-444444444444', 'ORD-20240901-00004', 'c9d0e1f2-a3b4-2c3d-6e5f-7a8b9c0d1e2f', 'shipped', 349.99, 20.00, 37.00, 0, 406.99, 'USD', 'JP', 'Tokyo', '100-0001', '2024-09-01 07:00:00+00', '2024-09-05 11:00:00+00', '2024-09-01 07:10:00', '2024-09-03 06:00:00+00', NULL),
('ord55555-5555-5555-5555-555555555555', 'ORD-20240905-00005', 'd0e1f2a3-b4c5-3d4e-7f6a-8b9c0d1e2f3a', 'processing', 1999.00, 0, 159.92, 100.00, 2058.92, 'USD', 'IN', 'Mumbai', '400001', '2024-09-05 13:00:00+00', '2024-09-06 09:00:00+00', '2024-09-05 13:05:00', NULL, NULL),

-- CHALLENGE: Cancelled order
('ord66666-6666-6666-6666-666666666666', 'ORD-20240415-00006', 'f6a7b8c9-d0e1-9f0a-3b2c-4d5e6f7a8b9c', 'cancelled', 250.00, 15.00, 26.50, 0, 291.50, 'EUR', 'US', 'Los Angeles', '90001', '2024-04-15 16:00:00+00', '2024-04-16 10:00:00+00', NULL, NULL, NULL),

-- CHALLENGE: Refunded order
('ord77777-7777-7777-7777-777777777777', 'ORD-20240501-00007', 'a7b8c9d0-e1f2-0a1b-4c3d-5e6f7a8b9c0d', 'refunded', 15000.00, 100.00, 0, 0, 15100.00, 'EUR', 'CA', 'Vancouver', 'V6B 1A1', '2024-05-01 15:00:00+00', '2024-05-20 09:00:00+00', '2024-05-01 15:30:00', '2024-05-05 08:00:00+00', '2024-05-10 14:00:00+00'),

-- Multi-item order
('ord88888-8888-8888-8888-888888888888', 'ORD-20240720-00008', 'e1f2a3b4-c5d6-4e5f-8a7b-9c0d1e2f3a4b', 'delivered', 1519.99, 30.00, 124.00, 75.00, 1598.99, 'USD', 'KR', 'Seoul', '04524', '2024-07-20 06:00:00+00', '2024-08-05 10:00:00+00', '2024-07-20 06:15:00', '2024-07-25 05:00:00+00', '2024-08-01 09:00:00+00'),

-- Pending order (no confirmation yet)
('ord99999-9999-9999-9999-999999999999', 'ORD-20240910-00009', 'a3b4c5d6-e7f8-6a7b-0c9d-1e2f3a4b5c6d', 'pending', 280.00, 35.00, 0, 0, 315.00, 'GBP', NULL, NULL, NULL, '2024-09-10 14:00:00+00', '2024-09-10 14:00:00+00', NULL, NULL, NULL);

-- =============================================================================
-- ORDER_ITEMS
-- =============================================================================
INSERT INTO order_items (id, order_id, product_id, seller_id, quantity, unit_price, total_price, currency, product_title, product_snapshot, created_at) VALUES
('item1111-1111-1111-1111-111111111111', 'ord11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 1, 1199.00, 1199.00, 'USD', 'iPhone 15 Pro Max 256GB', '{"color": "titanium"}', '2024-01-15 14:00:00+00'),
('item2222-2222-2222-2222-222222222222', 'ord22222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', 'b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 1, 450.00, 450.00, 'GBP', 'Premium Wool Overcoat', '{"size": "M"}', '2024-02-20 11:00:00+00'),
('item3333-3333-3333-3333-333333333333', 'ord33333-3333-3333-3333-333333333333', '66666666-6666-6666-6666-666666666666', 'c3d4e5f6-a7b8-6c7d-0e9f-1a2b3c4d5e6f', 1, 890.00, 890.00, 'EUR', 'Scandinavian Oak Dining Table', '{"seats": 6}', '2024-03-10 09:00:00+00'),
('item4444-4444-4444-4444-444444444444', 'ord44444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 1, 349.99, 349.99, 'USD', 'Sony WH-1000XM5 Headphones', '{"color": "black"}', '2024-09-01 07:00:00+00'),
('item5555-5555-5555-5555-555555555555', 'ord55555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 1, 1999.00, 1999.00, 'USD', 'MacBook Pro 14" M3 Pro', '{"chip": "M3 Pro"}', '2024-09-05 13:00:00+00'),
('item6666-6666-6666-6666-666666666666', 'ord66666-6666-6666-6666-666666666666', '99999999-9999-9999-9999-999999999999', 'e5f6a7b8-c9d0-8e9f-2a1b-3c4d5e6f7a8b', 1, 250.00, 250.00, 'EUR', 'Professional Football Boots', '{"size": 42}', '2024-04-15 16:00:00+00'),
('item7777-7777-7777-7777-777777777777', 'ord77777-7777-7777-7777-777777777777', '88888888-8888-8888-8888-888888888888', 'd4e5f6a7-b8c9-7d8e-1f0a-2b3c4d5e6f7a', 1, 15000.00, 15000.00, 'EUR', 'Vintage Rolex Submariner 1968', '{"year": 1968}', '2024-05-01 15:00:00+00'),
-- Multi-item order items
('item8888-8888-8888-8888-888888888888', 'ord88888-8888-8888-8888-888888888888', '11111111-1111-1111-1111-111111111111', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 1, 1199.00, 1199.00, 'USD', 'iPhone 15 Pro Max 256GB', '{"color": "titanium"}', '2024-07-20 06:00:00+00'),
('item9999-9999-9999-9999-999999999999', 'ord88888-8888-8888-8888-888888888888', '77777777-7777-7777-7777-777777777777', 'c3d4e5f6-a7b8-6c7d-0e9f-1a2b3c4d5e6f', 1, 320.00, 320.00, 'EUR', 'Professional Chef Knife Set', '{"pieces": 8}', '2024-07-20 06:00:00+00'),
('itemaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ord99999-9999-9999-9999-999999999999', '55555555-5555-5555-5555-555555555555', 'b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 1, 280.00, 280.00, 'GBP', 'Silk Evening Dress', '{"size": "S"}', '2024-09-10 14:00:00+00');

-- =============================================================================
-- PAYMENTS
-- Challenge: Contains DUPLICATE events (idempotency test)
-- =============================================================================
INSERT INTO payments (id, order_id, payment_provider, payment_provider_id, amount, currency, platform_fee, seller_payout, status, created_at, processed_at, event_id, event_timestamp) VALUES
-- Normal payments
('pay11111-1111-1111-1111-111111111111', 'ord11111-1111-1111-1111-111111111111', 'stripe', 'pi_abc123', 1323.26, 'USD', 39.70, 1160.10, 'completed', '2024-01-15 14:05:00+00', '2024-01-15 14:05:30+00', 'evt_001', '2024-01-15 14:05:00+00'),
('pay22222-2222-2222-2222-222222222222', 'ord22222-2222-2222-2222-222222222222', 'paypal', 'PAY-xyz789', 425.00, 'GBP', 12.75, 405.00, 'completed', '2024-02-20 11:10:00+00', '2024-02-20 11:10:45+00', 'evt_002', '2024-02-20 11:10:00+00'),
('pay33333-3333-3333-3333-333333333333', 'ord33333-3333-3333-3333-333333333333', 'stripe', 'pi_def456', 1122.95, 'EUR', 33.69, 800.10, 'completed', '2024-03-10 09:15:00+00', '2024-03-10 09:15:20+00', 'evt_003', '2024-03-10 09:15:00+00'),
('pay44444-4444-4444-4444-444444444444', 'ord44444-4444-4444-4444-444444444444', 'stripe', 'pi_ghi789', 406.99, 'USD', 12.21, 314.99, 'completed', '2024-09-01 07:05:00+00', '2024-09-01 07:05:15+00', 'evt_004', '2024-09-01 07:05:00+00'),
('pay55555-5555-5555-5555-555555555555', 'ord55555-5555-5555-5555-555555555555', 'stripe', 'pi_jkl012', 2058.92, 'USD', 61.77, 1799.00, 'processing', '2024-09-05 13:05:00+00', NULL, 'evt_005', '2024-09-05 13:05:00+00'),

-- Refunded payment
('pay66666-6666-6666-6666-666666666666', 'ord77777-7777-7777-7777-777777777777', 'stripe', 'pi_mno345', 15100.00, 'EUR', 453.00, 13500.00, 'refunded', '2024-05-01 15:10:00+00', '2024-05-01 15:10:30+00', 'evt_006', '2024-05-01 15:10:00+00'),

-- Multi-item order payment
('pay77777-7777-7777-7777-777777777777', 'ord88888-8888-8888-8888-888888888888', 'paypal', 'PAY-qrs456', 1598.99, 'USD', 47.97, 1362.10, 'completed', '2024-07-20 06:10:00+00', '2024-07-20 06:10:25+00', 'evt_007', '2024-07-20 06:10:00+00'),

-- CHALLENGE: DUPLICATE payment events (same event_id, different payment_id)
-- This simulates webhook replay - candidate must handle idempotency
('pay88888-8888-8888-8888-888888888888', 'ord33333-3333-3333-3333-333333333333', 'stripe', 'pi_def456', 1122.95, 'EUR', 33.69, 800.10, 'completed', '2024-03-10 09:15:05+00', '2024-03-10 09:15:25+00', 'evt_003', '2024-03-10 09:15:05+00'),  -- DUPLICATE of evt_003!
('pay99999-9999-9999-9999-999999999999', 'ord33333-3333-3333-3333-333333333333', 'stripe', 'pi_def456', 1122.95, 'EUR', 33.69, 800.10, 'completed', '2024-03-10 09:15:10+00', '2024-03-10 09:15:30+00', 'evt_003', '2024-03-10 09:15:10+00');  -- ANOTHER DUPLICATE!

-- =============================================================================
-- REVIEWS
-- =============================================================================
INSERT INTO reviews (id, product_id, order_item_id, reviewer_id, rating, title, body, is_verified_purchase, helpful_votes, status, moderated_at, created_at, updated_at) VALUES
('rev11111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'item1111-1111-1111-1111-111111111111', 'f6a7b8c9-d0e1-9f0a-3b2c-4d5e6f7a8b9c', 5, 'Amazing phone!', 'Best iPhone I''ve ever owned. Camera is incredible.', true, 42, 'approved', '2024-01-26 10:00:00+00', '2024-01-25 15:00:00+00', '2024-01-25 15:00:00+00'),
('rev22222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', 'item2222-2222-2222-2222-222222222222', 'a7b8c9d0-e1f2-0a1b-4c3d-5e6f7a8b9c0d', 4, 'Great quality, runs small', 'Beautiful coat but order a size up.', true, 18, 'approved', '2024-03-08 09:00:00+00', '2024-03-07 14:00:00+00', '2024-03-07 14:00:00+00'),
('rev33333-3333-3333-3333-333333333333', '66666666-6666-6666-6666-666666666666', 'item3333-3333-3333-3333-333333333333', 'b8c9d0e1-f2a3-1b2c-5d4e-6f7a8b9c0d1e', 5, 'Stunning craftsmanship', 'The table is even more beautiful in person. Solid construction.', true, 31, 'approved', '2024-03-28 11:00:00+00', '2024-03-27 16:00:00+00', '2024-03-27 16:00:00+00'),
('rev44444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', NULL, 'd0e1f2a3-b4c5-3d4e-7f6a-8b9c0d1e2f3a', 4, 'Good but pricey', 'Great noise cancellation but there are cheaper options.', false, 7, 'approved', '2024-04-10 08:00:00+00', '2024-04-09 12:00:00+00', '2024-04-09 12:00:00+00'),
-- Pending review (not yet moderated)
('rev55555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', NULL, 'e1f2a3b4-c5d6-4e5f-8a7b-9c0d1e2f3a4b', 3, 'Decent laptop', 'Good performance but battery life could be better.', false, 0, 'pending', NULL, '2024-09-08 10:00:00+00', '2024-09-08 10:00:00+00'),
-- Flagged review (potential fake)
('rev66666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', NULL, 'a3b4c5d6-e7f8-6a7b-0c9d-1e2f3a4b5c6d', 1, 'SCAM! DO NOT BUY!', 'This seller is a fraud! Never received my order!', false, 2, 'flagged', '2024-08-20 14:00:00+00', '2024-08-15 09:00:00+00', '2024-08-20 14:00:00+00');

-- =============================================================================
-- SELLER_TIER_HISTORY (SCD Type 2)
-- Challenge: Requires proper SCD modeling in dbt
-- =============================================================================
INSERT INTO seller_tier_history (user_id, tier, effective_from, effective_to, is_current, change_reason, created_at) VALUES
-- TechStorePro: bronze -> silver -> gold
('a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 'bronze', '2023-01-15 10:00:00+00', '2023-06-01 00:00:00+00', false, 'Initial tier', '2023-01-15 10:00:00+00'),
('a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 'silver', '2023-06-01 00:00:00+00', '2024-02-01 00:00:00+00', false, 'Sales milestone reached', '2023-06-01 00:00:00+00'),
('a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 'gold', '2024-02-01 00:00:00+00', NULL, true, 'Exceptional performance', '2024-02-01 00:00:00+00'),

-- FashionistaUK: silver -> gold -> platinum
('b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 'silver', '2022-06-20 08:00:00+00', '2023-01-01 00:00:00+00', false, 'Initial tier', '2022-06-20 08:00:00+00'),
('b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 'gold', '2023-01-01 00:00:00+00', '2024-01-01 00:00:00+00', false, 'Annual review upgrade', '2023-01-01 00:00:00+00'),
('b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e', 'platinum', '2024-01-01 00:00:00+00', NULL, true, 'Top seller status', '2024-01-01 00:00:00+00'),

-- SportsOutlet: bronze -> gold (skipped silver)
('e5f6a7b8-c9d0-8e9f-2a1b-3c4d5e6f7a8b', 'bronze', '2022-11-01 09:00:00+00', '2023-11-01 00:00:00+00', false, 'Initial tier', '2022-11-01 09:00:00+00'),
('e5f6a7b8-c9d0-8e9f-2a1b-3c4d5e6f7a8b', 'gold', '2023-11-01 00:00:00+00', NULL, true, 'Rapid growth bonus', '2023-11-01 00:00:00+00'),

-- ResellerPro: current silver
('e1f2a3b4-c5d6-4e5f-8a7b-9c0d1e2f3a4b', 'bronze', '2022-09-01 10:00:00+00', '2024-03-01 00:00:00+00', false, 'Initial tier', '2022-09-01 10:00:00+00'),
('e1f2a3b4-c5d6-4e5f-8a7b-9c0d1e2f3a4b', 'silver', '2024-03-01 00:00:00+00', NULL, true, 'Consistent sales', '2024-03-01 00:00:00+00');

-- =============================================================================
-- EVENT_LOG (CDC simulation)
-- Challenge: Events arrive out of order
-- =============================================================================
INSERT INTO event_log (event_type, entity_type, entity_id, event_data, event_timestamp, received_at, processed) VALUES
('order_created', 'order', 'ord11111-1111-1111-1111-111111111111', '{"status": "pending", "total": 1323.26}', '2024-01-15 14:00:00+00', '2024-01-15 14:00:01+00', true),
('order_confirmed', 'order', 'ord11111-1111-1111-1111-111111111111', '{"status": "confirmed"}', '2024-01-15 14:30:00+00', '2024-01-15 14:30:02+00', true),
('order_shipped', 'order', 'ord11111-1111-1111-1111-111111111111', '{"status": "shipped", "tracking": "1Z999AA10123456784"}', '2024-01-18 09:00:00+00', '2024-01-18 09:00:05+00', true),

-- CHALLENGE: Out-of-order events
('order_delivered', 'order', 'ord22222-2222-2222-2222-222222222222', '{"status": "delivered"}', '2024-03-02 12:00:00+00', '2024-03-02 12:00:10+00', true),
('order_shipped', 'order', 'ord22222-2222-2222-2222-222222222222', '{"status": "shipped"}', '2024-02-25 08:00:00+00', '2024-03-02 12:00:15+00', true),  -- Arrived AFTER delivered event!

('product_updated', 'product', '11111111-1111-1111-1111-111111111111', '{"price_old": 1249.00, "price_new": 1199.00}', '2024-06-01 10:00:00+00', '2024-06-01 10:00:03+00', true),
('review_created', 'review', 'rev11111-1111-1111-1111-111111111111', '{"rating": 5, "product_id": "11111111-1111-1111-1111-111111111111"}', '2024-01-25 15:00:00+00', '2024-01-25 15:00:02+00', true),

-- Unprocessed events
('user_updated', 'user', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', '{"seller_tier": "gold"}', '2024-02-01 00:00:00+00', '2024-09-10 10:00:00+00', false);
