with monthly_mrr as
         (select gp.user_id,
                 gp.game_name,
                 date_trunc('month', payment_date)::date as payment_month,
                 sum(gp.revenue_amount_usd)              as mrr
          from project.games_payments gp
          group by user_id,
                   payment_month,
                   game_name),
     user_monthly_mrr as
         (select mm.user_id,
                 mm.game_name,
                 mm.payment_month,
                 mm.mrr,
                 gpu.language,
                 gpu.has_older_device_model,
                 gpu.age
          from monthly_mrr as mm
                   left join project.games_paid_users gpu on
              mm.user_id = gpu.user_id
                  and mm.game_name = gpu.game_name),
     user_payments_history as
         (select umm.user_id,
                 umm.game_name,
                 umm.payment_month,
                 umm.mrr,
                 umm.language,
                 umm.has_older_device_model,
                 umm.age,
                 date(umm.payment_month - interval '1' month)                              as previous_calendar_month,
                 date(umm.payment_month + interval '1' month)                              as next_calendar_month,
                 lag(umm.mrr)
                 over (partition by umm.user_id, umm.game_name order by umm.payment_month) as previous_mrr,
                 lag(umm.payment_month)
                 over (partition by umm.user_id, umm.game_name order by umm.payment_month) as previous_payment_month,
                 lead(umm.payment_month)
                 over (partition by umm.user_id, umm.game_name order by umm.payment_month) as next_payment_month
          from user_monthly_mrr as umm),
     base_metrics as
         (select user_id,
                 game_name,
                 payment_month,
                 next_calendar_month,
                 mrr,
                 language,
                 has_older_device_model,
                 age,
                 case
                     when previous_payment_month is null then mrr
                     end as new_mrr,
                 case
                     when previous_payment_month is null then 1
                     end as new_paid_users,
                 case
                     when next_payment_month is null
                         or next_payment_month != next_calendar_month then (-1 * mrr)
                     end as churned_mrr,
                 case
                     when next_payment_month is null
                         or next_payment_month != next_calendar_month then 1
                     end as churned_users,
                 case
                     when previous_payment_month = previous_calendar_month
                         and mrr > previous_mrr then mrr - previous_mrr
                     end as expansion_mrr,
                 case
                     when previous_payment_month = previous_calendar_month
                         and mrr < previous_mrr then mrr - previous_mrr
                     end as contraction_mrr,
                 case
                     when previous_payment_month is not null
                         and previous_payment_month != previous_calendar_month then mrr
                     end as back_from_churn_mrr,
                 case
                     when previous_payment_month is not null
                         and previous_payment_month != previous_calendar_month then 1
                     end as back_from_churn_users
          from user_payments_history),
     unfolded_events as
         (select user_id,
                 game_name,
                 payment_month as metric_month,
                 language,
                 has_older_device_model,
                 age,
                 mrr,
                 1             as paid_users,
                 new_mrr,
                 new_paid_users,
                 expansion_mrr,
                 contraction_mrr,
                 back_from_churn_mrr,
                 back_from_churn_users,
                 null::numeric as churned_mrr,
                 null::int     as churned_users,
                 null::numeric as churn_base_mrr,
                 null::int     as churn_base_users
          from base_metrics

          union all
          -- ----------------------------------------------------------------
-- ДВА ВИПРАВЛЕННЯ ПОРІВНЯНО З ПОПЕРЕДНЬОЮ ВЕРСІЄЮ ЦІЄЇ ГІЛКИ / TWO FIXES COMPARED TO THE PREVIOUS VERSION OF THIS BRANCH
--
-- 1. Обмеження вікна даних (where нижче). / 1. Limiting the data window (the where below).
-- Раніше умовою було churn_month is not null, без верхньої межі. Через це всі, / Previously the condition was churn_month is not null, with no upper bound. Because of that, everyone
-- хто платив у останньому місяці даних (Dec 2022), отримували рядок відтоку / who paid in the last month of the data (Dec 2022) got a churn row
-- в Jan 2023 — але це не факт відтоку, а відсутність наступного платежу в даних. / in Jan 2023 - but that is not real churn, only the absence of a next payment in the data.
-- На дашборді з'являвся зайвий місяць із хибним провалом на весь грудневий MRR. / the dashboard showed an extra month with a false drop of the whole December MRR.
-- Тепер верхня межа — останній місяць платежів. / now the upper bound is the last month of payments.
--
-- 2. Гілка стала безумовною + колонки churn_base_mrr / churn_base_users. / 2. The branch became unconditional, plus the churn_base_mrr / churn_base_users columns.
-- Раніше рядок створювався тільки для тих, хто пішов, тому в даних не було / previously the row was created only for users who left, so the data had no
-- знаменника churn rate: churn rate місяця M = churned(M) / paid_users(M-1), / churn rate denominator: churn rate of month M = churned(M) / paid_users(M-1),
-- тобто два значення з РІЗНИХ міток осі часу, що в Tableau знову вимагало / i.e. two values from DIFFERENT points on the time axis, which in Tableau again required
-- LOOKUP(..., -1) і знову ламалося при виборі одного місяця у фільтрі дат. / LOOKUP(..., -1) and again broke when a single month was selected in the date filter.
-- Тепер рядок створюється для КОЖНОГО платежу: якщо користувач залишився, / now a row is created for EVERY payment: if the user stayed,
-- churned_* = NULL, але churn_base_* = 1 / mrr лишається, бо він входить / churned_* = NULL, but churn_base_* = 1 / mrr remains, because the user belongs
-- у базу "усі, хто платив у попередньому місяці". База лягає на той самий / to the base of "everyone who paid in the previous month". The base lands on the same
-- metric_month, що й сам відток, тому churn rate стає відношенням двох SUM / metric_month as the churn itself, so churn rate becomes a ratio of two SUMs
-- у межах одного місяця: / within a single month:
-- User Churn Rate % = SUM(churned_users) / SUM(churn_base_users)
-- MRR Churn Rate % = -SUM(churned_mrr) / SUM(churn_base_mrr)
-- Через безумовність metric_month тут — next_calendar_month, а не churn_month / because the branch is unconditional, metric_month here is next_calendar_month, not churn_month
-- (для тих, хто пішов, це те саме значення). / (for users who churned it is the same value).
          -- --------------------------------------------------------------
          select user_id,
                 game_name,
                 next_calendar_month as metric_month,
                 language,
                 has_older_device_model,
                 age,
                 null::numeric       as mrr,
                 null::int           as paid_users,
                 null::numeric       as new_mrr,
                 null::int           as new_paid_users,
                 null::numeric       as expansion_mrr,
                 null::numeric       as contraction_mrr,
                 null::numeric       as back_from_churn_mrr,
                 null::int           as back_from_churn_users,
                 churned_mrr,
                 churned_users,
                 mrr                 as churn_base_mrr,
                 1                   as churn_base_users
          from base_metrics
          where next_calendar_month <= (select max(payment_month) from monthly_mrr))
select *
from unfolded_events;
