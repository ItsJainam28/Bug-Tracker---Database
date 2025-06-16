/*
Bug Tracker App SQL SCRIPT
*/

/*
Dropping all the tables and sequences if they exist 
to make sure that there are no similar tables that exist
*/

--Drop sequences 
DROP SEQUENCE user_id_seq;
DROP SEQUENCE Bughistory_id_seq;
DROP SEQUENCE bugassignment_id_seq;
DROP SEQUENCE  projectmembership_id_seq;
DROP SEQUENCE project_id_seq;
DROP SEQUENCE bug_id_seq;
-- Drop BugPriority table
DROP TABLE BugPriority;

-- Drop BugAssignment table
DROP TABLE BugAssignment;

-- Drop BugStatus table
DROP TABLE BugStatus;

-- Drop Role table
DROP TABLE Role;

-- Drop ProjectMembership table
DROP TABLE ProjectMembership;

-- Drop BugHistory table
DROP TABLE BugHistory;

-- Drop Bugs table
DROP TABLE Bugs;

-- Drop Project table
DROP TABLE Project;

-- Drop Users table
DROP TABLE Users;

/*
1. Creating Sequence : For User Tables Primary key (User id) and Bug History
*/
CREATE SEQUENCE User_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCYCLE
  CACHE 20
  NOORDER;
/  

CREATE SEQUENCE bughistory_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCYCLE
  CACHE 20
  NOORDER;
/  
CREATE SEQUENCE bugassignment_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCYCLE
  CACHE 20
  NOORDER;
/  
CREATE SEQUENCE projectmembership_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCYCLE
  CACHE 20
  NOORDER;
/  

--Creating sequence for project
CREATE SEQUENCE project_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCYCLE
  CACHE 20
  NOORDER;
/
--Creating sequence for bug
CREATE SEQUENCE bug_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCYCLE
  CACHE 20
  NOORDER;
/

/*
2. Creating Tables - DDL for creating tables
*/
-- USER TABLE
CREATE TABLE Users (
    User_Id INT PRIMARY KEY,
    name VARCHAR2(140),
    email VARCHAR2(140),
    password VARCHAR2(140)
);
--Project table
CREATE TABLE Project (
    Project_id INT PRIMARY KEY,
    Name VARCHAR2(255),
    Description VARCHAR2(4000),
    Created_Date DATE,
    Created_by INT,
     FOREIGN KEY (Created_by) REFERENCES Users(User_Id)
);
--Bugs table
CREATE TABLE Bugs (
    Bug_id INT PRIMARY KEY,
    title VARCHAR2(255),
    Description VARCHAR2(4000),
    Status_id INT,
    Priority_id INT,
    Project_id INT,
    Reporter_id INT,
    Created_Date DATE,
    Updated_Date DATE,
    FOREIGN KEY (Project_id) REFERENCES Project(Project_id)
);
--Bug History table
CREATE TABLE BugHistory (
    History_Id INT PRIMARY KEY,
    Bug_Id INT,
    Time_Stamp TIMESTAMP,
    Field_Changed VARCHAR(255),
    Old_Value VARCHAR(255),
    New_Value VARCHAR(255),
    FOREIGN KEY (Bug_Id) REFERENCES Bugs(Bug_id)
);
--Project Membership table
CREATE TABLE ProjectMembership (
    ProjectMembership_id INT PRIMARY KEY,
    User_id INT,
    Project_id INT,
    Role_id INT,
    added_by INT,
    FOREIGN KEY (added_by) REFERENCES Users(User_Id),
    FOREIGN KEY (Project_id) REFERENCES Project(Project_id),
    FOREIGN KEY (User_id) REFERENCES Users(User_Id)
);
--Role Table (Reference table)
CREATE TABLE Role (
    Role_id INT PRIMARY KEY,
    Name VARCHAR(255)
);
-- BugStatus table (Reference table)
CREATE TABLE BugStatus (
    Status_id INT PRIMARY KEY,
    Status_Name VARCHAR(255)
);
--Bug Assignment table
CREATE TABLE BugAssignment (
    Bug_Assignment_id INT PRIMARY KEY,
    user_id INT,
    Bug_id INT,
    FOREIGN KEY (Bug_id) REFERENCES Bugs(Bug_id),
    FOREIGN KEY (user_id) REFERENCES Users(User_Id)
);
-- Bug Priority table (Reference table)
CREATE TABLE BugPriority (
    Priority_id INT PRIMARY KEY,
    Priority_Level VARCHAR(255)
);
--Constrains on the tables to enforce Business rules

--To ensure unique project name
ALTER TABLE Project
ADD CONSTRAINT UQ_Project_Name UNIQUE (Name);
--To ensure Priority id is valid in Bug table
ALTER TABLE Bugs
ADD CONSTRAINT CHK_Priority_id CHECK (Priority_id BETWEEN 1 AND 5);
--To ensure status id is valid
ALTER TABLE Bugs
ADD CONSTRAINT CHK_Status_id CHECK (Status_id BETWEEN 1 AND 5);
--Only one entry per user to project membership
ALTER TABLE ProjectMembership
ADD CONSTRAINT UQ_User_Project UNIQUE (User_id, Project_id);
-- To keep role valid
ALTER TABLE ProjectMembership
ADD CONSTRAINT CHK_Role_id CHECK (Role_id BETWEEN 1 AND 5);
--ONly one record per bug assignment
ALTER TABLE BugAssignment
ADD CONSTRAINT UQ_User_Bug UNIQUE (User_id, Bug_id);
/*
3. Creating Triggers for Sequences
*/
--Trigger 1 --> for project sequence
CREATE OR REPLACE TRIGGER project_id_trigger
BEFORE INSERT ON Project
FOR EACH ROW
BEGIN
    :new.Project_Id := project_id_seq.NEXTVAL;
END;
/
--Trigger 2 --> FOR USER SEQUENCE
CREATE OR REPLACE TRIGGER user_id_trigger
BEFORE INSERT ON Users
FOR EACH ROW
BEGIN
  SELECT user_id_seq.NEXTVAL INTO :new.User_Id FROM dual;
END;
/
--Trigger 3 --> for bug sequence
CREATE OR REPLACE TRIGGER bug_id_trigger
BEFORE INSERT ON Bugs
FOR EACH ROW
BEGIN
    SELECT bug_id_seq.NEXTVAL INTO :new.Bug_Id FROM dual;
END;
/
--Trigger 4 --> for bug ASSIGNMENT
CREATE OR REPLACE TRIGGER bugassignment_id_trigger
BEFORE INSERT ON bugassignment
FOR EACH ROW
BEGIN
    SELECT bugassignment_id_seq.NEXTVAL INTO :new.Bug_assignment_Id FROM dual;
END;
/
--Trigger 5 --> for PROJECTMEMBERSHIP
CREATE OR REPLACE TRIGGER projectmembership_id_trig
BEFORE INSERT ON ProjectMembership
FOR EACH ROW
BEGIN
  SELECT projectmembership_id_seq.NEXTVAL
  INTO :new.ProjectMembership_id
  FROM dual;
END;
/
/*
3. Creating Index
*/
--Creating INdex for Bug Title
CREATE INDEX idx_bugs_title ON Bugs(title);
--Creating INdex for user email 
CREATE INDEX idx_users_email ON Users(email);


/*
4. Creating Triggers
*/
/
--Trigger 1 -> For Auditing in Bughistory when A bug is inserted
CREATE OR REPLACE TRIGGER bug_insert_trigger
AFTER INSERT ON Bugs
FOR EACH ROW
DECLARE
    v_history_id BugHistory.History_Id%TYPE;
BEGIN
    -- Insert a new record into the BugHistory table
    INSERT INTO BugHistory (History_Id, Bug_Id, Time_Stamp, Field_Changed, Old_Value, New_Value)
    VALUES (bughistory_id_seq.NEXTVAL, :NEW.Bug_id, SYSTIMESTAMP, 'New Bug Inserted', NULL, NULL);
END;
/
--Trigger 2 -> For Auditing in Bughistory when A bug is updated
CREATE OR REPLACE TRIGGER bug_update_trigger
BEFORE UPDATE ON Bugs
FOR EACH ROW
DECLARE
    v_old_value VARCHAR2(4000);
BEGIN
    -- Check if any column has been updated and capture the changes
    IF :OLD.title != :NEW.title THEN
        v_old_value := :OLD.title;
        INSERT INTO BugHistory (History_Id, Bug_Id, Time_Stamp, Field_Changed, Old_Value, New_Value)
        VALUES (bughistory_id_seq.NEXTVAL, :NEW.Bug_id, SYSTIMESTAMP, 'Title Changed', v_old_value, :NEW.title);
    END IF;

    IF :OLD.Description != :NEW.Description THEN
        v_old_value := :OLD.Description;
        INSERT INTO BugHistory (History_Id, Bug_Id, Time_Stamp, Field_Changed, Old_Value, New_Value)
        VALUES (bughistory_id_seq.NEXTVAL, :NEW.Bug_id, SYSTIMESTAMP, 'Description Changed', v_old_value, :NEW.Description);
    END IF;

    IF :OLD.Status_id != :NEW.Status_id THEN
        SELECT Status_Name INTO v_old_value FROM BugStatus WHERE Status_id = :OLD.Status_id;
        INSERT INTO BugHistory (History_Id, Bug_Id, Time_Stamp, Field_Changed, Old_Value, New_Value)
        VALUES (bughistory_id_seq.NEXTVAL, :NEW.Bug_id, SYSTIMESTAMP, 'Status Changed', v_old_value, :NEW.Status_id);
    END IF;

    IF :OLD.Priority_id != :NEW.Priority_id THEN
        SELECT Priority_Level INTO v_old_value FROM BugPriority WHERE Priority_id = :OLD.Priority_id;
        INSERT INTO BugHistory (History_Id, Bug_Id, Time_Stamp, Field_Changed, Old_Value, New_Value)
        VALUES (bughistory_id_seq.NEXTVAL, :NEW.Bug_id, SYSTIMESTAMP, 'Priority Changed', v_old_value, :NEW.Priority_id);
    END IF;

END;
/
--Trigger 3 -> Auto assigning Project maanager role to the user who created the project
CREATE OR REPLACE TRIGGER auto_assign_pm_trig
AFTER INSERT ON Project
FOR EACH ROW
BEGIN
    INSERT INTO ProjectMembership (ProjectMembership_id, User_id, Project_id, Role_id, added_by)
    VALUES (projectmembership_id_seq.nextval, :NEW.Created_By,:NEW.Project_id, 3, :NEW.Created_By); -- Role_id 3 represents the Project Manager role
END;
/

/*
4. Procedures 
*/

--Procedure 1 --> To assign bugs to users
CREATE OR REPLACE PROCEDURE AssignBugProcedure(
    p_bug_id IN INT,
    p_assigned_user_id IN INT
)
IS
    v_user_project_membership INT;
BEGIN
    -- Check if the assigned user is part of the project
    SELECT COUNT(*)
    INTO v_user_project_membership
    FROM ProjectMembership
    WHERE User_id = p_assigned_user_id 
    AND Project_id = (SELECT Project_id FROM Bugs WHERE Bug_id = p_bug_id);

    IF v_user_project_membership = 0 THEN
        -- The assigned user is not part of the project, raise an error
        RAISE_APPLICATION_ERROR(-20001, 'Assigned user is not part of the project.');
    ELSE
        BEGIN
            -- Attempt to insert bug assignment
            INSERT INTO bugassignment VALUES(bugassignment_id_seq.nextval, p_assigned_user_id, p_bug_id);
            -- Output success message
            DBMS_OUTPUT.PUT_LINE('Bug assigned successfully.');
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                -- Handle case where bug is already assigned to the user
                RAISE_APPLICATION_ERROR(-20004, 'Bug is already assigned to the user.');
        END;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case where no project membership found for the user
        RAISE_APPLICATION_ERROR(-20002, 'Error: User project membership not found.');
    WHEN OTHERS THEN
        -- Handle other exceptions
        RAISE_APPLICATION_ERROR(-20003, 'Error: ' || SQLERRM);
END;
/
-- Procedure 2 --> To update Bug Status
CREATE OR REPLACE PROCEDURE UpdateBugStatusProcedure(
    p_bug_id IN INT,
    p_new_status_id IN INT
)
IS
    v_old_status_id INT;
BEGIN
    -- Retrieve the old status of the bug
    SELECT Status_id INTO v_old_status_id
    FROM Bugs
    WHERE Bug_id = p_bug_id;

    -- Check if the new status is different from the old status
    IF p_new_status_id != v_old_status_id THEN
        -- Update the status of the bug
        UPDATE Bugs
        SET Status_id = p_new_status_id
        WHERE Bug_id = p_bug_id;
        
        -- Output success message
        DBMS_OUTPUT.PUT_LINE('Bug status updated successfully.');
    ELSE
        -- Output message indicating status is not changed
        DBMS_OUTPUT.PUT_LINE('New status is same as old status.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case where bug id not found
        RAISE_APPLICATION_ERROR(-20001, 'Error: Bug ID not found.');
    WHEN OTHERS THEN
        -- Handle other exceptions
        RAISE_APPLICATION_ERROR(-20002, 'Error: ' || SQLERRM);
END;
/

/*
5. Functions
*/

-- Function1 --> To get the count of bugs for a specific project ID
CREATE OR REPLACE FUNCTION get_bug_count(p_project_id INT) RETURN INT
IS
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Bugs WHERE Project_id = p_project_id;
    RETURN v_count;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions here
        DBMS_OUTPUT.PUT_LINE('Error getting bug count: ' || SQLERRM);
        RETURN NULL;
END get_bug_count;

/
-- Function 2 --> To get the status of the bug by using bug id
CREATE OR REPLACE FUNCTION get_bug_status(
    p_bug_id IN INT
) RETURN VARCHAR2
IS
    v_status_name VARCHAR2(255);
BEGIN
    SELECT Status_Name INTO v_status_name
    FROM BugStatus
    WHERE Status_id = (SELECT Status_id FROM Bugs WHERE Bug_id = p_bug_id);
    
    RETURN v_status_name;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions here
        DBMS_OUTPUT.PUT_LINE('Error getting bug status: ' || SQLERRM);
        RETURN NULL;
END get_bug_status;
/

/*
6. User Management Package Specification
*/
CREATE OR REPLACE PACKAGE UserManagementPkg IS
    g_user_count INT := 0;
    -- Procedure to register a new user
    PROCEDURE RegisterUserProcedure(
        p_name     IN VARCHAR2,
        p_email    IN VARCHAR2,
        p_password IN VARCHAR2
    );

    -- Procedure to update user details
    PROCEDURE UpdateUserProcedure(
        p_user_id  IN INT,
        p_name     IN VARCHAR2,
        p_email    IN VARCHAR2,
        p_password IN VARCHAR2
    );

    -- Function to retrieve details of a user
    FUNCTION GetUserDetailsFunction(
        p_user_id IN INT
    ) RETURN Users%ROWTYPE;

    -- Function to validate user login
    FUNCTION ValidateUserFunction(
        p_email    IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN;

END UserManagementPkg;
/

/*
7. User Management Package Body
*/
CREATE OR REPLACE PACKAGE BODY UserManagementPkg IS


    -- Global variable to store the last login timestamp
    g_last_login TIMESTAMP;

    PROCEDURE RegisterUserProcedure(
        p_name     IN VARCHAR2,
        p_email    IN VARCHAR2,
        p_password IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Users (name, email, password)
        VALUES (p_name, p_email, p_password);
        -- Increment user count
        g_user_count := g_user_count + 1;
    EXCEPTION
        WHEN OTHERS THEN
            -- Handle registration failure
            DBMS_OUTPUT.PUT_LINE('Error registering user: ' || SQLERRM);
    END;

    PROCEDURE UpdateUserProcedure(
        p_user_id  IN INT,
        p_name     IN VARCHAR2,
        p_email    IN VARCHAR2,
        p_password IN VARCHAR2
    ) IS
    BEGIN
        UPDATE Users
        SET name = p_name,
            email = p_email,
            password = p_password
        WHERE User_Id = p_user_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Handle case where user ID not found
            DBMS_OUTPUT.PUT_LINE('User with ID ' || p_user_id || ' not found.');
        WHEN OTHERS THEN
            -- Handle other exceptions
            DBMS_OUTPUT.PUT_LINE('Error updating user: ' || SQLERRM);
    END;

    FUNCTION GetUserDetailsFunction(
        p_user_id IN INT
    ) RETURN Users%ROWTYPE IS
        v_user_details Users%ROWTYPE;
    BEGIN
        SELECT *
        INTO v_user_details
        FROM Users
        WHERE User_Id = p_user_id;

        RETURN v_user_details;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Handle case where user ID not found
            DBMS_OUTPUT.PUT_LINE('User with ID ' || p_user_id || ' not found.');
            RETURN NULL;
        WHEN OTHERS THEN
            -- Handle other exceptions
            DBMS_OUTPUT.PUT_LINE('Error getting user details: ' || SQLERRM);
            RETURN NULL;
    END;

    FUNCTION ValidateUserFunction(
        p_email    IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN IS
        v_user_id INT;
    BEGIN
        SELECT User_Id
        INTO v_user_id
        FROM Users
        WHERE email = p_email AND password = p_password;

        -- Update last login timestamp
        g_last_login := SYSTIMESTAMP;

        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Handle invalid login
            RETURN FALSE;
        WHEN OTHERS THEN
            -- Handle other exceptions
            DBMS_OUTPUT.PUT_LINE('Error validating user: ' || SQLERRM);
            RETURN FALSE;
    END;

END UserManagementPkg;
/

/*
***************************************
INSERTION OF SAMPLE DATA
***************************************
*/

/*
INSERTING DATA INTO USERS
*/
INSERT INTO Users (name, email, password) VALUES ('Alice Wonderland', 'alice@example.com', 'password1');
INSERT INTO Users (name, email, password) VALUES ('Bob Builder', 'bob@example.com', 'password2');
INSERT INTO Users (name, email, password) VALUES ('Charlie Chocolate', 'charlie@example.com', 'password3');
INSERT INTO Users (name, email, password) VALUES ('Dorothy Oz', 'dorothy@example.com', 'password4');
INSERT INTO Users (name, email, password) VALUES ('Edward Scissorhands', 'edward@example.com', 'password5');
INSERT INTO Users (name, email, password) VALUES ('Fiona Shrek', 'fiona@example.com', 'password6');
INSERT INTO Users (name, email, password) VALUES ('George Jungle', 'george@example.com', 'password7');
INSERT INTO Users (name, email, password) VALUES ('Harry Potter', 'harry@example.com', 'password8');
INSERT INTO Users (name, email, password) VALUES ('Indiana Jones', 'indiana@example.com', 'password9');
INSERT INTO Users (name, email, password) VALUES ('Jane Tarzan', 'jane@example.com', 'password10');

/*
INSERTING DATA INTO PROJECT
*/
INSERT INTO Project (Name, Description, Created_Date) VALUES ('WebApp Revamp', 'Revamping the core web application for better performance and UX.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('MobileApp Launch', 'Launching a new mobile app aimed at improving customer engagement.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('API Gateway Enhancement', 'Enhancing the API gateway for better security and scalability.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('Customer Feedback System', 'Building a new system to gather and analyze customer feedback.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('Internal Tooling Update', 'Updating internal tooling for development and operational efficiency.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('Cloud Migration Phase 1', 'The first phase of migrating services and databases to the cloud.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('New Payment Gateway', 'Integrating a new payment gateway to support additional payment methods.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('Data Analytics Platform', 'Developing a new platform for in-depth data analysis and reporting.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('Security Audit and Compliance', 'Conducting a thorough security audit and ensuring compliance with latest standards.', SYSDATE);
INSERT INTO Project (Name, Description, Created_Date) VALUES ('User Onboarding Experience', 'Redesigning the user onboarding experience for all digital platforms.', SYSDATE);
/*
INSERTING DATA INTO BUGSTATUS
*/
INSERT INTO BugStatus (Status_id, Status_Name) VALUES (1, 'Open');
INSERT INTO BugStatus (Status_id, Status_Name) VALUES (2, 'In Progress');
INSERT INTO BugStatus (Status_id, Status_Name) VALUES (3, 'Resolved');
INSERT INTO BugStatus (Status_id, Status_Name) VALUES (4, 'Closed');
INSERT INTO BugStatus (Status_id, Status_Name) VALUES (5, 'Reopened');
/*
INSERTING DATA INTO BUGPRIORITY
*/
INSERT INTO BugPriority (Priority_id, Priority_Level) VALUES (1, 'Low');
INSERT INTO BugPriority (Priority_id, Priority_Level) VALUES (2, 'Medium');
INSERT INTO BugPriority (Priority_id, Priority_Level) VALUES (3, 'High');
INSERT INTO BugPriority (Priority_id, Priority_Level) VALUES (4, 'Critical');
INSERT INTO BugPriority (Priority_id, Priority_Level) VALUES (5, 'Blocker');
/*
INSERTING DATA INTO BUGS
*/
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Login Issue', 'Users cannot login.', 1, 4, 1, 1, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Payment Failure', 'Payment does not process.', 2, 4, 2, 2, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Image Not Loading', 'Profile image fails to load.', 1, 3, 3, 3, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Email Delay', 'Notification emails delayed.', 2, 2, 4, 4, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('404 Error', 'Page not found error on Help page.', 1, 2, 5, 5, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Misaligned Text', 'Text on homepage is misaligned.', 3, 1, 6, 6, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Broken Link', 'Footer link is broken.', 1, 1, 7, 7, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Slow Performance', 'App is slow during peak hours.', 2, 3, 8, 8, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('Data Loss', 'Data loss on form submission.', 3, 4, 9, 9, CURRENT_DATE);
INSERT INTO Bugs (title, Description, Status_id, Priority_id, Project_id, Reporter_id, Created_Date) VALUES ('API Timeout', 'API responses are taking longer than expected.', 2, 3, 10, 10, CURRENT_DATE);
/*
INSERTING DATA INTO ROLE
*/
INSERT INTO Role (Role_id, Name) VALUES (1, 'Developer');
INSERT INTO Role (Role_id, Name) VALUES (2, 'Tester');
INSERT INTO Role (Role_id, Name) VALUES (3, 'Project Manager');
INSERT INTO Role (Role_id, Name) VALUES (4, 'UI/UX Designer');
INSERT INTO Role (Role_id, Name) VALUES (5, 'Product Owner');
/*
INSERTING DATA INTO 
*/
--INSERT INTO BugAssignment (user_id, Bug_id) VALUES (1, 1);
--INSERT INTO BugAssignment (user_id, Bug_id) VALUES (2, 2);
--INSERT INTO BugAssignment (user_id, Bug_id) VALUES (5, 3);
INSERT INTO BugAssignment (user_id, Bug_id) VALUES (4, 4);
INSERT INTO BugAssignment (user_id, Bug_id) VALUES (5, 5);
INSERT INTO BugAssignment (user_id, Bug_id) VALUES (6, 6);
INSERT INTO BugAssignment (user_id, Bug_id) VALUES (7, 7);
INSERT INTO BugAssignment (user_id, Bug_id) VALUES (8, 8);
INSERT INTO BugAssignment (user_id, Bug_id) VALUES (9, 9);
INSERT INTO BugAssignment (user_id, Bug_id) VALUES (10, 10);
/*
INSERTING DATA INTO PROJECTMEMBERSHIP
*/
-- Project 1 Membership
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (1, 1, 3, 1); -- Project Manager
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (2, 1, 1, 1); -- Developer
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (3, 1, 2, 1); -- Tester
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (4, 1, 4, 1); -- UI/UX Designer
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (5, 1, 5, 1); -- Product Owner

-- Project 2 Membership
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (6, 2, 3, 6); -- Project Manager
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (7, 2, 1, 6); -- Developer
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (8, 2, 2, 6); -- Tester
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (9, 2, 4, 6); -- UI/UX Designer
INSERT INTO ProjectMembership (User_id, Project_id, Role_id, added_by) VALUES (10, 2, 5, 6); -- Product Owner

/*
***************************************
 TESTING SCRIPT
***************************************
*/
/
-- Test the AssignBugProcedure
-- Test the UpdateBugStatusProcedure

DECLARE
    v_bug_id INT := 1; -- Bug ID to assign
    v_assigned_user_id INT := 2; -- User ID to assign the bug to
BEGIN
        DBMS_OUTPUT.PUT_LINE('TESTING PROCEDURE 1: ASSIGN BUG TO USER PROCEDURE');
        dBMS_OUTPUT.PUT_LINE('TEST CASE 1 : TO ASSIGN THE BUG SUCCESSFULLY');
    AssignBugProcedure(v_bug_id, v_assigned_user_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Test the AssignBugProcedure with an invalid assigned user ID
DECLARE
    v_bug_id INT := 1; -- Bug ID to assign
    v_assigned_user_id INT := 1000; -- Invalid user ID
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST CASE WHERE USER IS NOT PART OF PROJECT');
    AssignBugProcedure(v_bug_id, v_assigned_user_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
DECLARE
    v_bug_id INT := 1; -- Bug ID to assign
    v_assigned_user_id INT := 2; -- User ID to assign the bug to
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST CASE WHERE BUG IS ALREADY ASSIGNED');
    AssignBugProcedure(v_bug_id, v_assigned_user_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Test the UpdateBugStatusProcedure
DECLARE
    v_bug_id INT := 1; -- Bug ID to update
    v_new_status_id INT := 3; -- New status ID
    v_old_status VARCHAR2(255);
    v_new_status VARCHAR2(255);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TESTING PROCEDURE 2: UPDATE STATUS OF THE BUG');

    -- Get the current status of the bug
    SELECT Status_name INTO v_old_status
    FROM BugStatus
    WHERE Status_id = (SELECT Status_id FROM Bugs WHERE Bug_id = v_bug_id);

    DBMS_OUTPUT.PUT_LINE('Old Status of Bug ' || v_bug_id || ': ' || v_old_status);

    -- Call the procedure to update the status of the bug
    UpdateBugStatusProcedure(v_bug_id, v_new_status_id);

    -- Get the new status of the bug
    SELECT Status_name INTO v_new_status
    FROM BugStatus
    WHERE Status_id = v_new_status_id;

    DBMS_OUTPUT.PUT_LINE('New Status of Bug ' || v_bug_id || ': ' || v_new_status);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Test the get_bug_count function

DECLARE
    v_bug_count INT;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TESTING FUNCTION 1 -- GET BUG COUNT');
    v_bug_count := get_bug_count(1); -- Assuming project ID 1
    DBMS_OUTPUT.PUT_LINE('Bug count for project ID 1: ' || v_bug_count);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Test the get_bug_status function

DECLARE

    v_bug_id INT := 1; -- Bug ID to check status
    v_status VARCHAR2(255);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TESTING FUNCTION 2 -- GET BUG STATUS');
    v_status := get_bug_status(v_bug_id);
    DBMS_OUTPUT.PUT_LINE('Status of Bug ' || v_bug_id || ': ' || v_status);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing PACKAGE UsermanagementPkg:');
    DBMS_OUTPUT.PUT_LINE('Testing PROCEDURE OF PACKAGE: RegisterUserProcedure...');
    UserManagementPkg.RegisterUserProcedure('John Doe', 'john@example.com', 'password123');
    DBMS_OUTPUT.PUT_LINE('User registered successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing PROCEDURE OF PACKAGE: UpdateUserProcedure...');
    UserManagementPkg.UpdateUserProcedure(1, 'Jane Doe', 'jane@example.com', 'newpassword');
    DBMS_OUTPUT.PUT_LINE('User details updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
-- Test the GetUserDetailsFunction
DECLARE
    v_user_id INT := 1; -- User ID to retrieve details
    v_user_details Users%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing FUNCTION 1: GET USER DEATILS');
    v_user_details := UserManagementPkg.GetUserDetailsFunction(v_user_id);
    IF v_user_details.User_Id IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('User ID: ' || v_user_details.User_Id);
        DBMS_OUTPUT.PUT_LINE('Name: ' || v_user_details.name);
        DBMS_OUTPUT.PUT_LINE('Email: ' || v_user_details.email);
        DBMS_OUTPUT.PUT_LINE('Password: ' || v_user_details.password);
    END IF;
END;
/
-- Test the ValidateUserFunction
DECLARE
    v_valid_user BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing FUCNTION 2: USER VALIDATION');
    v_valid_user := UserManagementPkg.ValidateUserFunction('john@example.com', 'password123');
    IF v_valid_user THEN
        DBMS_OUTPUT.PUT_LINE('User login successful.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid credentials.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

COMMIT;