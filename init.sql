CREATE TABLE TBrand (
    id SERIAL PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL,
    daily_budget DECIMAL(10,2) NOT NULL,
    monthly_budget DECIMAL(10,2) NOT NULL,
    spent_today DECIMAL(10,2) DEFAULT 0,
    spent_monthly DECIMAL(10,2) DEFAULT 0,
    debt DECIMAL(10,2) DEFAULT 0
);


CREATE TABLE TCampaign (
    id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL,
    status VARCHAR(50) DEFAULT 'inactive',  -- 'active' o 'inactive'
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    activation_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES TBrand(id)
);


CREATE TABLE TSpend (
    id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL,
    spend_amount DECIMAL(10,2) NOT NULL,
    spend_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES TBrand(id)
);


CREATE OR REPLACE FUNCTION handle_spend_insert()
RETURNS TRIGGER AS $$
DECLARE
    remaining_daily_budget NUMERIC;
    excess NUMERIC;
BEGIN
    -- Get the remaining daily budget
    SELECT (daily_budget - spent_today)
    INTO remaining_daily_budget
    FROM TBrand WHERE id = NEW.brand_id;
 
    -- If there is enough budget, simply add the spend amount
    IF NEW.spend_amount <= remaining_daily_budget THEN
        UPDATE TBrand
        SET spent_today = spent_today + NEW.spend_amount,
            spent_monthly = spent_monthly + NEW.spend_amount
        WHERE id = NEW.brand_id;
    
    ELSE
        -- Calculate the excess amount that exceeds the daily budget
        excess := NEW.spend_amount - remaining_daily_budget;
 
        -- Update spent_today, spent_monthly, and debt
        UPDATE TBrand
        SET spent_today = daily_budget,  -- Set to max daily budget
            spent_monthly = spent_monthly + (NEW.spend_amount - excess),  -- Add only what fits
            debt = debt + excess  -- Add excess to debt
        WHERE id = NEW.brand_id;
 
        -- Disable all active campaigns for the brand
        UPDATE TCampaign
        SET status = 'inactive'
        WHERE brand_id = NEW.brand_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 
-- Attach trigger to TSpend table
CREATE TRIGGER trigger_handle_spend
BEFORE INSERT ON TSpend
FOR EACH ROW
EXECUTE FUNCTION handle_spend_insert();




----------------------------------------------------


CREATE OR REPLACE FUNCTION handle_campaign_insert()
RETURNS TRIGGER AS $$
DECLARE
    remaining_daily_budget NUMERIC;
BEGIN
    -- Get the remaining daily budget
    SELECT (daily_budget - spent_today)
    INTO remaining_daily_budget
    FROM TBrand WHERE id = NEW.brand_id;
 
    -- If there is enough budget, proceed with the insertion
    IF NEW.activation_cost <= remaining_daily_budget THEN
        UPDATE TBrand
        SET spent_today = spent_today + NEW.activation_cost,  -- Update daily spend
            spent_monthly = spent_monthly + NEW.activation_cost  -- Update monthly spend
        WHERE id = NEW.brand_id;
 
        RETURN NEW;
    ELSE
        -- Prevent insertion if the campaign exceeds the daily budget
        RAISE EXCEPTION 'Not enough daily budget to activate this campaign';
    END IF;
END;
$$ LANGUAGE plpgsql;
 
-- Attach trigger to TCampaign table
CREATE TRIGGER trigger_handle_campaign
BEFORE INSERT ON TCampaign
FOR EACH ROW
EXECUTE FUNCTION handle_campaign_insert();


-- Insert brands (TBrand)
INSERT INTO TBrand (id, brand_name, daily_budget, monthly_budget, spent_today, spent_monthly, debt)
VALUES
(1, 'Nike', 1000, 30000, 0, 0, 0),
(2, 'Adidas', 800, 25000, 0, 0, 0),
(3, 'Puma', 500, 15000, 0, 0, 0);

-- Insert campaigns (TCampaign)
INSERT INTO TCampaign (id, brand_id, status, start_time, end_time, activation_cost)
VALUES
(1, 1, 'active', '2025-03-16 08:00:00', '2025-03-16 20:00:00', 200),  -- Nike
(2, 1, 'active', '2025-03-16 09:00:00', '2025-03-16 18:00:00', 300),  
(3, 1, 'inactive', '2025-03-16 10:00:00', '2025-03-16 22:00:00', 400),  
 
(4, 2, 'active', '2025-03-16 07:00:00', '2025-03-16 21:00:00', 100),  -- Adidas
(5, 2, 'active', '2025-03-16 08:30:00', '2025-03-16 19:30:00', 250),  
(6, 2, 'inactive', '2025-03-16 11:00:00', '2025-03-16 23:00:00', 350),  
 
(7, 3, 'active', '2025-03-16 06:00:00', '2025-03-16 20:00:00', 10),  -- Puma
(8, 3, 'active', '2025-03-16 09:00:00', '2025-03-16 19:00:00', 180),  
(9, 3, 'inactive', '2025-03-16 12:00:00', '2025-03-16 20:00:00', 220);
 
-- Insert spend records (TSpend)
INSERT INTO TSpend (id, brand_id, spend_amount)
VALUES
 
(5, 3, 100), 
(6, 3, 100);
 







