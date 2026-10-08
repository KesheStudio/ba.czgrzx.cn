CREATE TABLE IF NOT EXISTS st_profile (
    character_id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '角色ID',

    -- 名称
    name_ja_jp_hg VARCHAR(25) NOT NULL COMMENT '日文名（汉字）',
    name_ja_jp_kj VARCHAR(25) NOT NULL COMMENT '日文名（片假名）',
    name_ja_jp_kk VARCHAR(25) NOT NULL COMMENT '日文名（平假名）',
    name_zh_cn VARCHAR(25) NOT NULL COMMENT '中文名（简体）',
    name_zh_tw VARCHAR(25) NOT NULL COMMENT '中文名（繁体）',
    name_en_us VARCHAR(25) NOT NULL COMMENT '英文名',
    name_ko_kr VARCHAR(25) NOT NULL COMMENT '韩文名',

    -- CV
    cv_zh_cn VARCHAR(25) NULL COMMENT '中文CV',
    cv_ja_jp VARCHAR(25) NULL COMMENT '日文CV',
    cv_ko_kr VARCHAR(25) NULL COMMENT '韩文CV',

    -- 基本信息
    age TINYINT UNSIGNED NOT NULL COMMENT '年龄',
    height SMALLINT UNSIGNED NOT NULL COMMENT '身高(cm)',
    birthday CHAR(4) NOT NULL COMMENT '生日12月12日 = 1212,1月1日 = 101',
    artist VARCHAR(50) NOT NULL COMMENT '画师',
    launch_date DATE NOT NULL COMMENT '上线日期',
    cg_level TINYINT UNSIGNED NOT NULL COMMENT '记忆大厅解锁等级',

    -- 势力信息
    college_id TINYINT UNSIGNED NOT NULL COMMENT '学院ID',
    club_id TINYINT UNSIGNED NOT NULL COMMENT '社团ID',

    -- 角色介绍
    momo_talk_status_message VARCHAR(255) NULL COMMENT '桃桃对话状态消息',
    introduction VARCHAR(500) NOT NULL COMMENT '角色介绍',
    gift_preferences JSON NOT NULL DEFAULT (JSON_ARRAY())
        COMMENT '礼物偏好，对象数组 [{gift_id, preference_level}]',
    interactive_furniture JSON NOT NULL DEFAULT (JSON_ARRAY())
        COMMENT '互动家具ID数组 [1,3,5]',
    interactive_props JSON NOT NULL DEFAULT (JSON_ARRAY())
        COMMENT '互动道具ID数组 [1,3,5]',

    -- 属性
    attack_type TINYINT UNSIGNED NOT NULL COMMENT '攻击类型',
    defense_type TINYINT UNSIGNED NOT NULL COMMENT '防御类型',
    star TINYINT UNSIGNED NOT NULL COMMENT '星级 1-5',
    battle_role TINYINT UNSIGNED NOT NULL COMMENT '战斗职责',
    release_type TINYINT UNSIGNED NOT NULL COMMENT '限定/常驻 0=常驻 1=限定',
    weapon_type TINYINT UNSIGNED NOT NULL COMMENT '武器种类',
    adapt_city TINYINT UNSIGNED NOT NULL COMMENT '市街适应',
    adapt_outdoor TINYINT UNSIGNED NOT NULL COMMENT '室外适应',
    adapt_indoor TINYINT UNSIGNED NOT NULL COMMENT '室内适应',
    cover_interaction TINYINT UNSIGNED NOT NULL COMMENT '掩体互动',
    position_front_back TINYINT UNSIGNED NOT NULL COMMENT '编队位置 0=前 1=后',
    positioning_type TINYINT UNSIGNED NOT NULL COMMENT '站位类型',

    -- 其他
    sp_group_id INT UNSIGNED NULL COMMENT 'SP角色ID',
    
    PRIMARY KEY (character_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生基础信息表';