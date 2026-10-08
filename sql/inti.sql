CREATE DATABASE IF NOT EXISTS cn_czgrzx_ba
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE cn_czgrzx_ba;

-- =========================================================
-- 1. 角色主表
-- =========================================================
CREATE TABLE IF NOT EXISTS student (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '角色id',

  -- 名称
  names JSON NOT NULL COMMENT '多语言名称结构体',
  name_cn VARCHAR(25)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(names, '$.name_cn'))) VIRTUAL COMMENT '简体中文名',
  name_tw VARCHAR(25)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(names, '$.name_tw'))) VIRTUAL COMMENT '繁体中文名（台湾）',
  name_jp_hg VARCHAR(50)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(names, '$.name_jp_hg'))) VIRTUAL COMMENT '日文平假名',
  name_jp_kk VARCHAR(50)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(names, '$.name_jp_kk'))) VIRTUAL COMMENT '日文片假名',
  name_jp_kj VARCHAR(50)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(names, '$.name_jp_kj'))) VIRTUAL COMMENT '日文汉字',
  name_en VARCHAR(50)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(names, '$.name_en'))) VIRTUAL COMMENT '英文名',
  name_ko VARCHAR(25)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(names, '$.name_ko'))) VIRTUAL COMMENT '韩文名',

  -- CV
  cv JSON NOT NULL DEFAULT (JSON_OBJECT()) COMMENT '中日韩CV结构体(cv_cn/cv_jp/cv_ko，可选)',
  cv_cn VARCHAR(50)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(cv, '$.cv_cn'))) VIRTUAL COMMENT '中文CV',
  cv_jp VARCHAR(50)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(cv, '$.cv_jp'))) VIRTUAL COMMENT '日文CV',
  cv_ko VARCHAR(50)
    GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(cv, '$.cv_ko'))) VIRTUAL COMMENT '韩文CV',

  age TINYINT UNSIGNED NOT NULL COMMENT '年龄',
  height SMALLINT UNSIGNED NOT NULL COMMENT '身高（cm）',
  birthday SMALLINT UNSIGNED NOT NULL COMMENT '生日，516 表示 5月16日',
  artist VARCHAR(50) NOT NULL COMMENT '画师',
  launch_date DATE NOT NULL COMMENT '上线日期',
  cg_level INT NOT NULL COMMENT '记忆大厅解锁等级',

  -- 逻辑引用
  weapon_id INT UNSIGNED NOT NULL COMMENT '专属武器id，逻辑引用 weapon 表',
  favorite_items_id INT UNSIGNED NOT NULL COMMENT '爱用品id，逻辑引用 favorite_items 表',
  college_id INT UNSIGNED NOT NULL COMMENT '学院id，逻辑引用 college 表',
  club_id INT UNSIGNED NOT NULL COMMENT '社团id，逻辑引用 club 表',

  interest JSON NOT NULL COMMENT '兴趣数组',
  momo_talk_status_message VARCHAR(255) NULL COMMENT '桃桃对话状态消息',
  introduction TEXT NULL COMMENT '角色介绍',

  gift_preferences JSON NOT NULL DEFAULT (JSON_ARRAY())
    COMMENT '礼物偏好，对象数组 [{gift_id, preference_level}]',
  interactive_furniture JSON NOT NULL DEFAULT (JSON_ARRAY())
    COMMENT '互动家具ID数组 [1,3,5]',
  interactive_props JSON NOT NULL DEFAULT (JSON_ARRAY())
    COMMENT '互动道具ID数组 [1,3,5]',
  associated_role JSON NOT NULL DEFAULT (JSON_ARRAY())
    COMMENT '关联角色ID数组，表示该角色的不同SP',

  attack_type TINYINT UNSIGNED NOT NULL COMMENT '攻击类型',
  defense_type TINYINT UNSIGNED NOT NULL COMMENT '防御类型',
  job_type TINYINT UNSIGNED NOT NULL COMMENT '职业类型',
  positioning_type TINYINT UNSIGNED NOT NULL COMMENT '定位类型',

  terrain_adaptability JSON NOT NULL COMMENT '地形适应 {block, outdoor, indoor}',
  initial_star_rating TINYINT UNSIGNED NOT NULL COMMENT '初始星级',

  PRIMARY KEY (id),

  UNIQUE KEY uk_name_cn (name_cn),
  UNIQUE KEY uk_name_tw (name_tw),
  UNIQUE KEY uk_name_jp_kj (name_jp_kj),
  UNIQUE KEY uk_name_en (name_en),
  UNIQUE KEY uk_name_ko (name_ko),

  KEY idx_cv_cn (cv_cn),
  KEY idx_cv_jp (cv_jp),
  KEY idx_cv_ko (cv_ko),
  KEY idx_weapon_id (weapon_id),
  KEY idx_favorite_items_id (favorite_items_id),
  KEY idx_college_id (college_id),
  KEY idx_club_id (club_id),

  -- names 结构校验
  CONSTRAINT chk_names_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "object",
        "required": ["name_cn", "name_tw", "name_jp_hg", "name_jp_kk", "name_jp_kj", "name_en", "name_ko"],
        "properties": {
          "name_cn":    { "type": "string", "minLength": 1, "maxLength": 25 },
          "name_tw":    { "type": "string", "minLength": 1, "maxLength": 25 },
          "name_jp_hg": { "type": "string", "minLength": 1, "maxLength": 50 },
          "name_jp_kk": { "type": "string", "minLength": 1, "maxLength": 50 },
          "name_jp_kj": { "type": "string", "minLength": 1, "maxLength": 50 },
          "name_en":    { "type": "string", "minLength": 1, "maxLength": 50 },
          "name_ko":    { "type": "string", "minLength": 1, "maxLength": 25 }
        },
        "additionalProperties": false
      }',
      names
    )
  ),

  -- cv 结构校验
  CONSTRAINT chk_cv_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "object",
        "properties": {
          "cv_cn": { "type": "string", "minLength": 1, "maxLength": 50 },
          "cv_jp": { "type": "string", "minLength": 1, "maxLength": 50 },
          "cv_ko": { "type": "string", "minLength": 1, "maxLength": 50 }
        },
        "additionalProperties": false
      }',
      cv
    )
  ),

  -- interest
  CONSTRAINT chk_interest_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "array",
        "items": { "type": "string", "minLength": 1, "maxLength": 50 },
        "uniqueItems": true
      }',
      interest
    )
  ),

  -- gift_preferences
  CONSTRAINT chk_gift_preferences_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "array",
        "items": {
          "type": "object",
          "required": ["gift_id", "preference_level"],
          "properties": {
            "gift_id":          { "type": "integer", "minimum": 1 },
            "preference_level": { "type": "integer", "minimum": 1, "maximum": 5 }
          },
          "additionalProperties": false
        },
        "uniqueItems": true
      }',
      gift_preferences
    )
  ),

  -- interactive_furniture
  CONSTRAINT chk_interactive_furniture_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "array",
        "items": { "type": "integer", "minimum": 1 },
        "uniqueItems": true
      }',
      interactive_furniture
    )
  ),

  -- interactive_props
  CONSTRAINT chk_interactive_props_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "array",
        "items": { "type": "integer", "minimum": 1 },
        "uniqueItems": true
      }',
      interactive_props
    )
  ),

  -- associated_role
  CONSTRAINT chk_associated_role_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "array",
        "items": { "type": "integer", "minimum": 1 },
        "uniqueItems": true
      }',
      associated_role
    )
  ),

  -- terrain_adaptability
  CONSTRAINT chk_terrain_adaptability_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "object",
        "required": ["block", "outdoor", "indoor"],
        "properties": {
          "block":   { "type": "integer", "minimum": 1, "maximum": 5 },
          "outdoor": { "type": "integer", "minimum": 1, "maximum": 5 },
          "indoor":  { "type": "integer", "minimum": 1, "maximum": 5 }
        },
        "additionalProperties": false
      }',
      terrain_adaptability
    )
  ),

  INDEX idx_interest ((CAST(interest AS CHAR(50) ARRAY))),
  INDEX idx_gift_pref_gift_id (
    (CAST(gift_preferences->'$[*].gift_id' AS UNSIGNED ARRAY))
  ),
  INDEX idx_interactive_furniture ((CAST(interactive_furniture AS UNSIGNED ARRAY))),
  INDEX idx_interactive_props ((CAST(interactive_props AS UNSIGNED ARRAY))),
  INDEX idx_associated_role ((CAST(associated_role AS UNSIGNED ARRAY)))

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='学生基础信息表';


-- =========================================================
-- 2. 技能表（1:1）
-- =========================================================
CREATE TABLE IF NOT EXISTS student_skill (
  student_id INT UNSIGNED NOT NULL COMMENT '角色id',

  ex_skill_id  INT UNSIGNED NULL COMMENT 'EX技能id，逻辑引用 skill 表',
  ns_skill_id  INT UNSIGNED NULL COMMENT 'NS技能id',
  ps_skill_id  INT UNSIGNED NULL COMMENT 'PS技能id',
  ss_skill_id  INT UNSIGNED NULL COMMENT 'SS技能id',
  wps_skill_id INT UNSIGNED NULL COMMENT 'WPS技能id',

  gns_level1_skill_id INT UNSIGNED NULL COMMENT 'GNS等级1技能id',
  gns_level2_skill_id INT UNSIGNED NULL COMMENT 'GNS等级2技能id',
  gns_level3_skill_id INT UNSIGNED NULL COMMENT 'GNS等级3技能id',

  ls_character_id INT UNSIGNED NULL COMMENT 'LS关联角色id，逻辑引用 student 表',
  ls_skill_id     INT UNSIGNED NULL COMMENT 'LS技能id',

  PRIMARY KEY (student_id),

  KEY idx_ex_skill (ex_skill_id),
  KEY idx_ns_skill (ns_skill_id),
  KEY idx_ps_skill (ps_skill_id),
  KEY idx_ss_skill (ss_skill_id),
  KEY idx_wps_skill (wps_skill_id),
  KEY idx_gns_l1 (gns_level1_skill_id),
  KEY idx_gns_l2 (gns_level2_skill_id),
  KEY idx_gns_l3 (gns_level3_skill_id),
  KEY idx_ls_char (ls_character_id),
  KEY idx_ls_skill (ls_skill_id)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='角色技能表';


-- =========================================================
-- 3. 语音表（1:N）
-- =========================================================
CREATE TABLE IF NOT EXISTS student_voice (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id INT UNSIGNED NOT NULL COMMENT '角色id',

  voice_path    VARCHAR(255)     NOT NULL COMMENT '语音文件路径',
  voice_type    SMALLINT UNSIGNED NOT NULL COMMENT '语音类型',
  voice_name    VARCHAR(100)     NOT NULL COMMENT '语音名称',
  voice_content VARCHAR(255)     NULL     COMMENT '语音内容',
  language      VARCHAR(10)      NOT NULL COMMENT '语言 cn/jp/ko/en',

  sort_order INT NOT NULL DEFAULT 0 COMMENT '排序',

  PRIMARY KEY (id),
  KEY idx_student_id (student_id),
  KEY idx_language (language),
  KEY idx_voice_type (voice_type)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='角色语音表';


-- =========================================================
-- 4. 画廊表（1:1）
-- =========================================================
CREATE TABLE IF NOT EXISTS student_gallery (
  student_id INT UNSIGNED NOT NULL COMMENT '角色id',

  official_introduction_image_path VARCHAR(255) NULL COMMENT '官方介绍图',
  memory_hall_image_path            VARCHAR(255) NULL COMMENT '记忆大厅图',

  jp_image_path VARCHAR(255) NULL COMMENT '日服立绘图',
  tw_image_path VARCHAR(255) NULL COMMENT '台服立绘图',
  tv_image_path VARCHAR(255) NULL COMMENT 'TV动画立绘图',

  PRIMARY KEY (student_id)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='角色画廊基础图表';


-- =========================================================
-- 5. 画廊衍生图表（1:N）
-- =========================================================
CREATE TABLE IF NOT EXISTS student_gallery_derivative (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id INT UNSIGNED NOT NULL COMMENT '角色id',

  title      VARCHAR(255) NULL     COMMENT '标题',
  image_path VARCHAR(255) NOT NULL COMMENT '图片路径',
  sort_order INT          NOT NULL DEFAULT 0 COMMENT '排序',

  PRIMARY KEY (id),
  KEY idx_student_id (student_id)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='角色画廊衍生图表';


-- =========================================================
-- 6. 表情图表（1:N）
-- =========================================================
CREATE TABLE IF NOT EXISTS student_expression (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id INT UNSIGNED NOT NULL COMMENT '角色id',

  image_path VARCHAR(255) NOT NULL COMMENT '表情图路径',
  sort_order INT          NOT NULL DEFAULT 0 COMMENT '排序',

  PRIMARY KEY (id),
  KEY idx_student_id (student_id)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='角色表情图表';


-- =========================================================
-- 7. 视频表（1:N）
-- =========================================================
CREATE TABLE IF NOT EXISTS student_video (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id INT UNSIGNED NOT NULL COMMENT '角色id',

  title      VARCHAR(255) NOT NULL COMMENT '视频标题',
  path       VARCHAR(255) NOT NULL COMMENT '视频路径',
  sort_order INT          NOT NULL DEFAULT 0 COMMENT '排序',

  PRIMARY KEY (id),
  KEY idx_student_id (student_id)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='角色视频表';


-- =========================================================
-- 8. 属性表（1:N，min/max 各一行）
-- =========================================================
CREATE TABLE IF NOT EXISTS student_attribute (
  student_id     INT UNSIGNED NOT NULL COMMENT '角色id',
  attribute_type ENUM('min','max') NOT NULL COMMENT '属性类型',

  attack_power              INT NOT NULL DEFAULT 0 COMMENT '攻击力',
  defense                   INT NOT NULL DEFAULT 0 COMMENT '防御力',
  health                    INT NOT NULL DEFAULT 0 COMMENT '生命值',
  healing_power             INT NOT NULL DEFAULT 0 COMMENT '治愈力',
  hit_rate                  INT NOT NULL DEFAULT 0 COMMENT '命中值',
  dodgevalue                INT NOT NULL DEFAULT 0 COMMENT '闪避值',
  critical_hit_value        INT NOT NULL DEFAULT 0 COMMENT '暴击值',
  critical_damage_rate      INT NOT NULL DEFAULT 0 COMMENT '暴击伤害率',
  stable_value              INT NOT NULL DEFAULT 0 COMMENT '安定值',
  range_value               INT NOT NULL DEFAULT 0 COMMENT '射程',
  group_control_enhancement INT NOT NULL DEFAULT 0 COMMENT '群控强化',
  group_resistance          INT NOT NULL DEFAULT 0 COMMENT '群控抵抗',
  ammo_count                INT NOT NULL DEFAULT 0 COMMENT '弹药数',
  extra_ammo                INT NOT NULL DEFAULT 0 COMMENT '额外弹药',
  defense_penetration       INT NOT NULL DEFAULT 0 COMMENT '防御穿透',
  recovery_rate             INT NOT NULL DEFAULT 0 COMMENT '回复率',
  cost_resilience           INT NOT NULL DEFAULT 0 COMMENT 'Cost恢复力',

  weapon             JSON NOT NULL COMMENT '武器属性 {weapon_id, level, health, attack_power}',
  ger                JSON NOT NULL COMMENT '装备数组',
  favorite_items     JSON NOT NULL COMMENT '爱用品属性 {favorite_items_id, critical_damage}',
  ability_liberation JSON NOT NULL COMMENT '能力解放 {healing_power, attack_power, health}',
  bond_level_rewards JSON NOT NULL COMMENT '羁绊奖励数组',

  PRIMARY KEY (student_id, attribute_type),

  -- weapon 结构
  CONSTRAINT chk_weapon_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "object",
        "required": ["weapon_id"],
        "properties": {
          "weapon_id":    { "type": "integer", "minimum": 1 },
          "level":        { "type": "integer", "minimum": 0 },
          "health":       { "type": "integer", "minimum": 0 },
          "attack_power": { "type": "integer", "minimum": 0 }
        },
        "additionalProperties": false
      }',
      weapon
    )
  ),

  -- ger 结构
  CONSTRAINT chk_ger_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "array",
        "items": {
          "type": "object",
          "required": ["ger_type", "ger_slot"],
          "properties": {
            "ger_type":             { "type": "integer", "minimum": 1 },
            "ger_slot":             { "type": "integer", "minimum": 1 },
            "attack_power_rate":    { "type": "integer" },
            "critical_damage":      { "type": "integer" },
            "critical_hit_value":   { "type": "integer" },
            "health":               { "type": "integer" },
            "health_rate":          { "type": "integer" },
            "group_resistance":     { "type": "integer" }
          },
          "additionalProperties": false
        }
      }',
      ger
    )
  ),

  -- favorite_items 结构
  CONSTRAINT chk_favorite_items_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "object",
        "required": ["favorite_items_id"],
        "properties": {
          "favorite_items_id": { "type": "integer", "minimum": 1 },
          "critical_damage":   { "type": "integer", "minimum": 0 }
        },
        "additionalProperties": false
      }',
      favorite_items
    )
  ),

  -- ability_liberation 结构
  CONSTRAINT chk_ability_liberation_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "object",
        "properties": {
          "healing_power": { "type": "integer", "minimum": 0 },
          "attack_power":  { "type": "integer", "minimum": 0 },
          "health":        { "type": "integer", "minimum": 0 }
        },
        "additionalProperties": false
      }',
      ability_liberation
    )
  ),

  -- bond_level_rewards 结构
  CONSTRAINT chk_bond_level_rewards_json CHECK (
    JSON_SCHEMA_VALID(
      '{
        "type": "array",
        "items": {
          "type": "object",
          "required": ["character_id", "level"],
          "properties": {
            "character_id": { "type": "integer", "minimum": 1 },
            "level":        { "type": "integer", "minimum": 0 },
            "attack_power": { "type": "integer", "minimum": 0 },
            "health":       { "type": "integer", "minimum": 0 }
          },
          "additionalProperties": false
        }
      }',
      bond_level_rewards
    )
  )

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci
  COMMENT='角色属性表';