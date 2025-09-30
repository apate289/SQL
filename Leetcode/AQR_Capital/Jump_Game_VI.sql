/*SQL Solution (T-SQL)

SQL doesn’t have deque structures natively, but we can mimic DP using a recursive CTE or window functions.
For large n this is inefficient compared to Python, but here’s the idea:
*/
-- nums table (Idx INT, Val INT)
WITH DP AS (
    SELECT Idx, CAST(Val AS BIGINT) AS Score
    FROM nums
    WHERE Idx = 0

    UNION ALL

    SELECT n.Idx,
           n.Val + MAX(d.Score) OVER (
                PARTITION BY n.Idx
                ORDER BY d.Idx
                ROWS BETWEEN k PRECEDING AND 1 PRECEDING
           ) AS Score
    FROM nums n
    JOIN DP d ON d.Idx BETWEEN n.Idx - k AND n.Idx - 1
)
SELECT TOP 1 Score
FROM DP
ORDER BY Idx DESC;
/*
Explanation:

Start with index 0 → score = nums[0].

For each index i, find the max dp[j] where i-k <= j < i.

Score at i = nums[i] + that max.

At the end, take the score at the last index.
*/

/*
-----------------------------------------------------------------------------------------
                              Second Method
-----------------------------------------------------------------------------------------
dp[i]=nums[i]+max(dp[j])for i−k≤j<i

So we need a sliding window maximum over the last k rows of dp.

🔹 SQL Implementation (T-SQL style)
-- Example input table
-- CREATE TABLE nums (Idx INT PRIMARY KEY, Val INT);

-- INSERT INTO nums VALUES
-- (0, 1), (1, -1), (2, -2), (3, 4), (4, -7), (5, 3);

🔹 Explanation

Start with base case dp[0] = nums[0].

For each row b.Idx, look back up to k rows using:

MAX(dp) OVER (ORDER BY b.Idx ROWS BETWEEN k PRECEDING AND 1 PRECEDING)


→ This computes the best score within the last k steps.

Add current value nums[i].

Final answer = score at last index.

🔹 Example

For nums = [1, -1, -2, 4, -7, 3], k = 2:

dp[0] = 1

dp[1] = -1 + dp[0] = 0

dp[2] = -2 + max(dp[0], dp[1]) = -1

dp[3] = 4 + max(dp[1], dp[2]) = 4

dp[4] = -7 + max(dp[2], dp[3]) = -3

dp[5] = 3 + max(dp[3], dp[4]) = 7

✅ Final = 7
*/
WITH Base AS (
    SELECT Idx, CAST(Val AS BIGINT) AS Val
    FROM nums
),
DP AS (
    SELECT
        Idx,
        CASE WHEN Idx = 0 THEN Val END AS dp
    FROM Base
)
SELECT TOP 1 dp AS MaxScore
FROM (
    SELECT 
        b.Idx,
        b.Val + MAX(d.dp) OVER (
            ORDER BY b.Idx
            ROWS BETWEEN k PRECEDING AND 1 PRECEDING
        ) AS dp
    FROM Base b
    JOIN DP d ON d.Idx = 0
) Final
ORDER BY Idx DESC;
