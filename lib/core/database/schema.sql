-- family_member：家庭成员
CREATE TABLE family_member (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  relation TEXT NOT NULL,          -- self / spouse / child
  birthday TEXT,                   -- ISO8601: yyyy-MM-dd
  created_at TEXT NOT NULL
);

-- renewal_policy：证件更新规则
CREATE TABLE renewal_policy (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  document_type TEXT NOT NULL,     -- residence_card / passport / etc
  country TEXT,                    -- CN / JP / null
  months_before INTEGER NOT NULL,  -- 提前几个月可申请
  is_default INTEGER NOT NULL,     -- 1 = 内置规则
  created_at TEXT NOT NULL
);

-- document：证件
CREATE TABLE document (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  member_id INTEGER NOT NULL,
  document_type TEXT NOT NULL,
  country TEXT,
  document_number TEXT,
  expiry_date TEXT NOT NULL,        -- yyyy-MM-dd
  renewal_policy_id INTEGER,
  remark TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY(member_id) REFERENCES family_member(id)
);

-- reminder_state：提醒状态机
CREATE TABLE reminder_state (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  document_id INTEGER NOT NULL,
  status TEXT NOT NULL,             -- NORMAL / REMINDING / PAUSED
  remind_start_date TEXT NOT NULL,  -- yyyy-MM-dd
  expected_finish_date TEXT,        -- PAUSED 时使用
  last_notified_at TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY(document_id) REFERENCES document(id)
);
