
SELECT TOP 100 * FROM [dbo].[game_sessions]

SELECT TOP 100 * FROM [dbo].[games]

SELECT TOP 100 * FROM [dbo].[paying_method]

SELECT TOP 100 * FROM [dbo].[players]

SELECT TOP 100 *,
	SUM(IIF(action_type = 'loss', amount * -1, amount)) OVER( PARTITION BY SESSION_ID ORDER by action_id)
FROM [dbo].[session_details]
WHERE SESSION_ID = 1