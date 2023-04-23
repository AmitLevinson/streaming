use Arena;


SELECT TOP 100 * FROM [dbo].[game_sessions]

SELECT TOP 100 * FROM [dbo].[games]

SELECT TOP 100 * FROM [dbo].[paying_method]

SELECT TOP 100 * FROM [dbo].[players]

SELECT TOP 100 * FROM [dbo].[session_details]


-- Question 1: Payment method
SELECT PLAYER_ID,
	email_address,
	credit_card_type,
	credit_card_number
FROM (
	SELECT P.PLAYER_ID,
	email_address,
	credit_card_type,
	credit_card_number,
	payment_method_rank = ROW_number () OVER (PARTITION BY P.PLAYER_ID ORDER BY CASE CREDIT_CARD_TYPE
															when 'AMERICANEXPRESS' THEN 1
															when 'MASTERCARD' THEN 2
															when 'VISA' THEN 3
															ELSE NULL 
														END)
	FROM [dbo].[players] p
	LEFT JOIN [dbo].[paying_method] PMETHOD on p.player_id = pmethod.player_id 
	) AS RANKED_PAYMENTS
WHERE payment_method_rank = 1

-- 2. Count of players by age group and gender
select *
from (
select p.player_id,
	gender,
	age_group,
	credit_card_type	
FROM [dbo].[players] p
LEFT JOIN [dbo].[paying_method] PMETHOD on p.player_id = pmethod.player_id 
) AS PVT
PIVOT (
	COUNT(PLAYER_ID)
	FOR CREDIT_CARD_TYPE IN (AMERICANEXPRESS, MASTERCARD, VISA)
) AS PVTTABLE
order by gender, age_group

-- 3. Display the number of sessions for each game, rank it at the end
SELECT *,
	ROW_NUMBER() OVER (ORDER BY TOTAL_SESSIONS DESC)
FROM (
	SELECT TOP 100 game_name,
		count(session_id) AS TOTAL_SESSIONS
	FROM [dbo].[games] games
	LEFT JOIN [dbo].[game_sessions] gamesession on games.id = gamesession.game_id
	group by game_name
) AS AGGREGATE_GAMES


-- 4. Return the games according to total minutes played
WITH TOTAL_MINUTES_GAMES AS (
	SELECT TOP 100 GAME_NAME,
		SUM(DATEDIFF(MINUTE, SESSION_BEGIN_DATE, SESSION_END_DATE)) AS TOTAL_MINUTES
	FROM [dbo].[games] games
	LEFT JOIN [dbo].[game_sessions] gamesession on games.id = gamesession.game_id
	group by game_name
)

SELECT *,
	ROW_NUMBER () OVER(ORDER BY TOTAL_MINUTES DESC) AS GAME_RANK
FROM TOTAL_MINUTES_GAMES

-- 5. show for each age_group the game in which most minutes were played
SELECT DISTINCT age_group,
	CROSS_TABLE.*
FROM [dbo].[players] playersOuter
CROSS APPLY	(
	SELECT TOP 1 
		GAME_NAME,
		SUM(DATEDIFF(MINUTE, SESSION_BEGIN_DATE, SESSION_END_DATE)) AS TOTAL_MINUTES
	FROM 
	[dbo].[players] players
	left join [dbo].[game_sessions] gsession on gsession.player_id = players.player_id
	LEFT JOIN [dbo].[games] games ON gsession.game_id = GAMES.ID
	WHERE PLAYERS.AGE_GROUP = playersOuter.AGE_GROUP
	GROUP BY AGE_GROUP, GAME_NAME
	ORDER BY TOTAL_MINUTES DESC
	) AS CROSS_TABLE

-- 6. DISPLAY THE BALANCE THROUGHOUT EACH GAME SESSION
SELECT TOP 100 *,
	SUM(IIF(ACTION_TYPE = 'LOSS', AMOUNT * -1, AMOUNT)) OVER(PARTITION BY SDETAILS.SESSION_ID ORDER BY ACTION_ID) AS BALANCE
FROM [dbo].[game_sessions] GSESSIONS
LEFT JOIN [dbo].[session_details] SDETAILS ON GSESSIONS.session_id = SDETAILS.session_id



-- 11. Company's profit/loss
with session_balance as (
	select YEAR(SESSION_BEGIN_DATE) AS SessionYear,
		DATEPART(quarter, session_begin_date) as SessionQuarter,
		GSESSIONS.session_id,
		total_balance = sum(IIF(ACTION_TYPE = 'LOSS', AMOUNT * -1, AMOUNT))
	FROM [dbo].[game_sessions] GSESSIONS
	LEFT JOIN [dbo].[session_details] SDETAILS ON GSESSIONS.session_id = SDETAILS.session_id
	group by YEAR(SESSION_BEGIN_DATE),
		DATEPART(quarter, session_begin_date),
		GSESSIONS.session_id
		)

select SessionYear,
	SessionQuarter,
	sum(case when total_balance < 0 then total_balance * -1 END) as house_gains,
	sum(case when total_balance > 0 then total_balance * -1 END) as house_losses,
	sum(total_balance) * -1 as overall_gain_loss
from session_balance
group by SessionYear,
	SessionQuarter
order by SessionYear,
	SessionQuarter



-- 12. Top 3 best months and worst months
with session_balance as (
	select YEAR(SESSION_BEGIN_DATE) AS SessionYear,
		DATEPART(month, session_begin_date) as SessionQuarter,
		GSESSIONS.session_id,
		total_balance = sum(IIF(ACTION_TYPE = 'LOSS', AMOUNT * -1, AMOUNT))
	FROM [dbo].[game_sessions] GSESSIONS
	LEFT JOIN [dbo].[session_details] SDETAILS ON GSESSIONS.session_id = SDETAILS.session_id
	group by YEAR(SESSION_BEGIN_DATE),
		DATEPART(month, session_begin_date),
		GSESSIONS.session_id
		),

aggregate_year_month as (
	select SessionYear,
		SessionQuarter,
		sum(case when total_balance < 0 then total_balance * -1 END) as house_gains,
		sum(case when total_balance > 0 then total_balance * -1 END) as house_losses,
		sum(total_balance) * -1 as overall_gain_loss
	from session_balance
	group by SessionYear,
		SessionQuarter
),

ranked_months as (
	select top 100 *,
		'Gain Top-' + cast(row_number () over(order by overall_gain_loss desc) as nvarchar(max)) overall_rank_top,
		row_number () over(order by overall_gain_loss desc) as rank_top,
		'Loss Top-' + cast(row_number () over(order by overall_gain_loss asc) as nvarchar(max)) as overall_rank_bottom,
		row_number () over(order by overall_gain_loss asc) as rank_bottom
	from aggregate_year_month
	)

select sessionYear,
	SessionQuarter,
	house_gains,
	house_losses,
	overall_gain_loss,
	overall_rank_top
from ranked_months
where rank_top <= 3
union 
select sessionYear,
	SessionQuarter,
	house_gains,
	house_losses,
	overall_gain_loss,
	overall_rank_bottom
from ranked_months
where rank_bottom <= 3