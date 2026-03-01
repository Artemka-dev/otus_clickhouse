# 1. Создание таблицы

```sql
CREATE TABLE user_actions (
    user_id UInt64,
    action String,
    expense UInt64
) ENGINE = MergeTree()
ORDER BY (user_id, action);
```

# 2. Создание словаря

```sql
CREATE or replace DICTIONARY users_dict (
    user_id UInt64,
    email String
)
PRIMARY KEY user_id
SOURCE(FILE(path '/var/lib/clickhouse/user_files/users.csv' format 'CSV'))
LAYOUT(FLAT())
LIFETIME(100);
```

Заранее закинул файл в контейнер по нужному пути

# 3. Вставка данных

```sql
INSERT INTO user_actions VALUES
(1, 'purchase', 1000),
(1, 'purchase', 1500),
(1, 'click', 0),
(1, 'click', 0),
(1, 'view', 0),
(2, 'purchase', 2000),
(2, 'purchase', 2500),
(2, 'click', 0),
(2, 'view', 0),
(2, 'view', 0),
(3, 'purchase', 3000),
(3, 'click', 0),
(3, 'click', 0),
(3, 'click', 0),
(3, 'view', 0),
(4, 'purchase', 4000),
(4, 'purchase', 3500),
(4, 'click', 0),
(4, 'view', 0),
(4, 'view', 0),
(5, 'purchase', 5000),
(5, 'click', 0),
(5, 'click', 0),
(5, 'view', 0),
(5, 'view', 0);
```

# 4. Итоговый запрос с dictGet и оконной функцией

```sql
SELECT DISTINCT 
    dictGet('users_dict', 'email', user_id) AS email,
    action,
    expense,
    SUM(expense) OVER (PARTITION BY action ORDER BY user_id) AS cumulative_sum_by_action
FROM user_actions
ORDER BY email;
```

### Результат выполнения:

![alt text](image.png)