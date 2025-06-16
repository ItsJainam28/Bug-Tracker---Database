# 🐛 Bug Tracker Database Project
### *Database Systems Course - Final Project*
---

## 📚 **Project Overview**

This is a comprehensive bug tracking database system developed as part of my Database Systems course. The project demonstrates practical application of database design principles, normalization, PL/SQL programming, and advanced database features learned throughout the semester.

### **Learning Objectives Achieved**
- ✅ **Database Design**: Applied normalization principles (1NF, 2NF, 3NF)
- ✅ **Entity Relationship Modeling**: Created comprehensive ER diagrams
- ✅ **SQL Mastery**: Implemented complex queries and joins
- ✅ **PL/SQL Programming**: Developed procedures, functions, and packages
- ✅ **Database Security**: Implemented user authentication and access control
- ✅ **Data Integrity**: Applied constraints and validation rules

---

## 🎯 **Project Requirements Met**

### **Core Requirements**
- [x] **Minimum 8 tables** with proper relationships
- [x] **Primary and Foreign Keys** correctly implemented
- [x] **Normalization** to 3rd Normal Form
- [x] **Stored Procedures** (2 required, 2 implemented)
- [x] **Functions** (2 required, 2 implemented)
- [x] **Triggers** (3 required, 5 implemented)
- [x] **Package** with multiple procedures/functions
- [x] **Sample Data** with realistic test cases

### **Advanced Features Implemented**
- 🔄 **Audit Trail System**: Automatic change tracking
- 🔐 **User Management**: Complete authentication system
- 📊 **Business Logic**: Comprehensive validation rules
- ⚡ **Performance Optimization**: Strategic indexing

---

## 🏗️ **Database Schema Design**


### **Table Structure**
| Table Name | Records | Primary Key | Foreign Keys | Purpose |
|------------|---------|-------------|--------------|---------|
| **Users** | 10+ | User_Id | - | Store user information |
| **Project** | 10+ | Project_Id | Created_by → Users | Manage projects |
| **Bugs** | 10+ | Bug_Id | Project_Id → Project | Track issues |
| **BugHistory** | Auto | History_Id | Bug_Id → Bugs | Audit changes |
| **ProjectMembership** | 10+ | ProjectMembership_Id | User_Id, Project_Id | Team assignments |
| **BugAssignment** | 7+ | Bug_Assignment_Id | User_Id, Bug_Id | Task assignments |
| **BugStatus** | 5 | Status_Id | - | Reference table |
| **BugPriority** | 5 | Priority_Id | - | Reference table |
| **Role** | 5 | Role_Id | - | Reference table |

---

## 💻 **PL/SQL Implementation**

### **Stored Procedures**
```sql
-- Procedure 1: Smart Bug Assignment
AssignBugProcedure(p_bug_id, p_assigned_user_id)
├── Validates user is project member
├── Prevents duplicate assignments
└── Provides error handling

-- Procedure 2: Bug Status Management
UpdateBugStatusProcedure(p_bug_id, p_new_status_id)
├── Checks for status changes
├── Updates bug record
└── Triggers audit trail
```

### **Functions**
```sql
-- Function 1: Project Metrics
get_bug_count(p_project_id) RETURN INT
├── Counts bugs per project
└── Returns integer value

-- Function 2: Status Lookup
get_bug_status(p_bug_id) RETURN VARCHAR2
├── Retrieves current bug status
└── Returns status name
```

### **Triggers**
1. **Auto-increment triggers** (5) - Manage primary keys using sequences
2. **Audit trigger** - Records all bug changes to BugHistory
3. **Business logic trigger** - Auto-assigns project manager role

### **Package: UserManagementPkg**
- `RegisterUserProcedure()` - Add new users
- `UpdateUserProcedure()` - Modify user details
- `GetUserDetailsFunction()` - Retrieve user information
- `ValidateUserFunction()` - Authenticate users

---

## 🔧 **Database Features Demonstrated**

### **Normalization Applied**
- **1NF**: All attributes contain atomic values
- **2NF**: Eliminated partial dependencies
- **3NF**: Removed transitive dependencies

### **Constraints Implemented**
- **Primary Keys**: Unique identifiers for all tables
- **Foreign Keys**: Maintain referential integrity
- **Check Constraints**: Validate status and priority ranges
- **Unique Constraints**: Prevent duplicate assignments
- **Not Null**: Ensure required fields are populated

### **Indexing Strategy**
- **Email Index**: Fast user lookups
- **Bug Title Index**: Efficient searching
- **Composite Indexes**: Optimized join operations

---

## 📊 **Test Data & Validation**

### **Sample Data Included**
- **10 Users**: Diverse user profiles with realistic names
- **10 Projects**: Various project types and descriptions
- **10 Bugs**: Different priorities and statuses
- **Role Assignments**: Complete team structures
- **Bug Assignments**: Realistic task distributions

### **Test Cases Implemented**
```sql
-- Testing Procedures
✓ Successful bug assignment
✓ Invalid user assignment (error handling)
✓ Duplicate assignment prevention
✓ Status update validation

-- Testing Functions
✓ Bug count calculation
✓ Status retrieval
✓ Error handling for invalid inputs

-- Testing Package
✓ User registration
✓ Profile updates
✓ User authentication
✓ Data retrieval
```

---

## 🚀 **How to Run the Project**

### **Prerequisites**
- Oracle Database (11g or higher)
- SQL*Plus or Oracle SQL Developer
- Basic understanding of SQL and PL/SQL

### **Setup Instructions**
1. **Download the script**
   ```bash
   git clone https://github.com/yourusername/bug-tracker-database.git
   ```

2. **Run the SQL script**
   ```sql
   -- In SQL*Plus or SQL Developer
   @bug_tracker_script.sql
   ```

3. **Verify setup**
   ```sql
   -- Check if all tables are created
   SELECT table_name FROM user_tables;
   
   -- Check sample data
   SELECT COUNT(*) FROM Users;
   SELECT COUNT(*) FROM Bugs;
   ```

### **Testing the Implementation**
The script includes comprehensive test cases that demonstrate:
- All procedures working correctly
- Functions returning expected results
- Triggers firing appropriately
- Package functionality

---

## 📈 **Learning Outcomes**

### **Technical Skills Developed**
- **Database Design**: ER modeling, normalization, schema design
- **SQL Programming**: Complex queries, joins, subqueries
- **PL/SQL Development**: Procedures, functions, packages, triggers
- **Data Modeling**: Relationships, constraints, referential integrity
- **Performance Tuning**: Indexing strategies, query optimization

### **Problem-Solving Applications**
- **Real-world Scenario**: Bug tracking system design
- **Business Logic**: Project management workflows
- **Data Integrity**: Validation and error handling
- **User Management**: Authentication and authorization
- **Audit Trail**: Change tracking and history

---

## 🎓 **Academic Reflection**

This project successfully demonstrates the practical application of database concepts learned in class. The implementation showcases:

- **Theoretical Knowledge**: Applied normalization rules and ER modeling
- **Practical Skills**: Developed working database with real functionality
- **Problem Solving**: Handled complex business requirements
- **Code Quality**: Implemented proper error handling and documentation
- **Testing**: Comprehensive validation of all components

The bug tracking system serves as an excellent example of how database principles apply to real-world software development scenarios.

---

## 🔍 **Code Quality Features**

- **Comprehensive Comments**: All code sections documented
- **Error Handling**: Proper exception management
- **Consistent Naming**: Clear, descriptive identifiers
- **Modular Design**: Reusable components
- **Test Coverage**: All features validated

---


## 📋 **Project Statistics**

```
📊 Implementation Summary
├── 9 Tables created with relationships
├── 6 Sequences for auto-increment
├── 5 Triggers for automation
├── 2 Stored procedures
├── 2 Functions
├── 1 Package (4 components)
├── 15+ Constraints applied
├── 50+ Sample records
└── 100% Test coverage
```

---

