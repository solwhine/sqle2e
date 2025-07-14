USE PreProd;
GO

INSERT INTO [dev].[DeploymentLog] (
    releaseVersion,
    deployedBy,
    deployedOn
)
VALUES (
    '2.0',
    SYSTEM_USER,
    SYSDATETIME()
);