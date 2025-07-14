-- Create deployment log table if it doesn't exist
IF OBJECT_ID('dev.DeploymentLog', 'U') IS NULL
BEGIN
    CREATE TABLE dev.DeploymentLog (
        releaseVersion NVARCHAR(10),
        deployedBy     SYSNAME,
        deployedOn     DATETIME
    );
END

-- Insert log row
INSERT INTO dev.DeploymentLog (releaseVersion, deployedBy, deployedOn)
VALUES ('2.0', SYSTEM_USER, SYSDATETIME());