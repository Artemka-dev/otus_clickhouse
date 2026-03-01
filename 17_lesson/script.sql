-- Создание пользователя jhon с паролем qwerty
CREATE USER jhon IDENTIFIED WITH sha256_password BY 'qwerty';

-- Создание роли devs
CREATE ROLE devs;

-- Выдача права SELECT на любую таблицу для роли devs
GRANT SELECT ON *.* TO devs;

-- Назначение роли devs пользователю jhon
GRANT devs TO jhon;


SELECT 
    name,
    auth_type,
    auth_params,
    host_ip,
    host_names,
    default_database
FROM system.users 
WHERE name = 'jhon';