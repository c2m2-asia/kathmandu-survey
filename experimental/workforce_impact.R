# Imports
source("~/projects/c2m2/kathmandu-survey/utils/functions.R")
source("~/projects/c2m2/kathmandu-survey/utils/constants.R")

# Parameters
survey_data_path <- paste0(ROOT_URL, "raw/data/workers_data_20210510.xlsx")

# Survey data
workers_data <- IO.XlsSheetToDF(excel_sheets(survey_data_path)[1], survey_data_path)

# Remove rows with NAs
workers <- workers_data %>% filter(!is.na(m_gender))


# Code
workers <- workers %>% mutate(d_is_worker = T)

# Get Lost Jobs split
workers <- workers %>% mutate(d_lost_job = ifelse((i_empl_covid_effects__1 == 1 | i_empl_covid_effects__2 == 1), T, F ))
workers <- workers %>% mutate(d_kept_job = ifelse((i_empl_covid_effects__1 != 1 & i_empl_covid_effects__2 != 1), T, F ))

SET1 <- c("d_is_worker","d_lost_job","d_kept_job")
RPRT.SaveChartData(workers, SET1, "LostOrKeptJobSplit")


workers <- workers %>% mutate(d_lost_job_but_working_now = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status == 1 | i_empl_jb_prsnt_status == 2)), T, F ))
workers <- workers %>% mutate(d_lost_job_still_no_work = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status != 1 & i_empl_jb_prsnt_status != 2)), T, F ))

SET1 <- c("d_lost_job","d_lost_job_but_working_now","d_lost_job_still_no_work")
RPRT.SaveChartData(workers, SET1, "LostJobsSplit")




# workers <- workers %>% mutate(d_occptn_travel_and_tour_guides = ifelse((b_empl_occpatn_pre_covid__2 == 1 | b_empl_occpatn_pre_covid__3 == 1 | b_empl_occpatn_pre_covid__4 == 1 | b_empl_occpatn_pre_covid__5 == 1 | b_empl_occpatn_pre_covid__15 == 1), T, F ) )
# workers <- workers %>% mutate(d_occptn_travel_and_tour_other = ifelse((b_empl_occpatn_pre_covid__6 == 1 | b_empl_occpatn_pre_covid__7 == 1 | b_empl_occpatn_pre_covid__8 == 1 | b_empl_occpatn_pre_covid__9 == 1), T, F ) )
# workers <- workers %>% mutate(d_occptn_accomodation_hotel_food = ifelse((b_empl_occpatn_pre_covid__10 == 1 | b_empl_occpatn_pre_covid__11 == 1 | b_empl_occpatn_pre_covid__12 == 1 | b_empl_occpatn_pre_covid__13 == 1 | b_empl_occpatn_pre_covid__14 == 1), T, F ) )
# workers <- workers %>% mutate(d_occptn_othr = ifelse((b_empl_occpatn_pre_covid__16 == 1), T, F ) )
# 
# 
# workersss <- workers %>% filter(d_lost_job_still_no_work == T)
# SET1 <- c(
#           "d_occptn_travel_and_tour_guides",
#           "d_occptn_travel_and_tour_other",
#           "d_occptn_accomodation_hotel_food",
#           "d_occptn_othr"
#           )
# SaveChartData(workersss, SET1, "LostJobsBySectorMultiple")

# Presently employed + employment status change split

# Get stayed employed split
workers <- workers %>% mutate(d_stayed_employed = ifelse((i_empl_covid_effects__1 != 1 & i_empl_covid_effects__2 != 1), T, F ))
workers <- workers %>% mutate(d_employed_but_in_low_salary = ifelse(((i_empl_covid_effects__4 == 1) & (i_empl_covid_effects__1 != 1) & (i_empl_covid_effects__2 != 1)), T, F ))
workers <- workers %>% mutate(d_employed_kept_salary = ifelse(((i_empl_covid_effects__4 != 1) & (i_empl_covid_effects__1 != 1) & (i_empl_covid_effects__2 != 1)), T, F ))


workers <- workers %>% mutate(d_presently_employed = ifelse((d_stayed_employed == T | d_lost_job_but_working_now == T), T, F ))
workers <- workers %>% mutate(d_presently_unemployed = ifelse((d_presently_employed != T), T, F ))


SET1 <- c("d_is_worker","d_presently_employed","d_presently_unemployed")
RPRT.SaveChartData(workers, SET1, "PresentlyEmployedUnemployedSplit")


# Presently employed + lost salary
workers <- workers %>% mutate(d_presently_employed = ifelse((d_stayed_employed == T | d_lost_job_but_working_now == T), T, F ))
workers <- workers %>% mutate(d_presently_employed_salary_cut = ifelse((d_presently_employed == T & i_empl_lst_date_full_salary == 1), T, F ))
workers <- workers %>% mutate(d_presently_employed_back_to_old_salary = ifelse(d_presently_employed == T &  (i_empl_lst_date_full_salary == 2 | i_empl_lst_date_full_salary == 3 | i_empl_lst_date_full_salary == 4 | i_empl_lst_date_full_salary == 5 ), T, F ))
SET3 <- c("d_presently_employed", "d_presently_employed_salary_cut", "d_presently_employed_back_to_old_salary")
RPRT.SaveChartData(workers, SET3, "PresentlyEmployedSalaryCutSplit")



SET3 <- c("d_presently_employed", "d_lost_job_but_working_now", "d_stayed_employed")
RPRT.SaveChartData(workers, SET3, "PresentlyEmployedEmplStatusSplit")



SET2 <- c("d_stayed_employed","d_employed_kept_salary","d_employed_but_in_low_salary")
RPRT.SaveChartData(workers, SET2, "StayedEmployedSplit")

# # Get stayed employed by sector split
# workersss <- workers %>% filter(d_stayed_employed == T)
# SET1 <- c(
#           "d_occptn_travel_and_tour_guides",
#           "d_occptn_travel_and_tour_other",
#           "d_occptn_accomodation_hotel_food",
#           "d_occptn_othr"
# )
# SaveChartData(workersss, SET1, "HeldJobsBySectorMultiple")













# Get time since last salary dist for presently employed folks
workers_presently_employed <- workers %>% filter(d_presently_employed == T)
RPRT.SaveDistData(workers_presently_employed, "i_empl_lst_date_full_salary", "LastDateFullSalaryDistPresentlyEmployed")


# # Presently employed split by sector change
# workers <- workers %>% mutate(d_presently_employed_swtch_occupatn = ifelse((d_presently_employed == T &  (i_empl_jb_in_tourism_change == 1 | i_empl_jb_in_tourism_change_add == 1) ), T, F ))
# workers <- workers %>% mutate(d_presently_employed_same_occupatn = ifelse((d_presently_employed == T &  (i_empl_jb_in_tourism_change == 2 | i_empl_jb_in_tourism_change_add == 2) ), T, F ))
# SET3 <- c("d_presently_employed", "d_presently_employed_swtch_occupatn", "d_presently_employed_same_occupatn")
# SaveChartData(workers, SET3, "PresentlyEmployedOccupationSplit")
# 


# Get savings compared to 2019 dist
RPRT.SaveDistData(workers, "p_econ_self_savings_chng_today_v_19", "SavingsChangeDist")
# workersss <- workers %>% select(i_empl_jb_prsnt_status, i_empl_jb_in_tourism_change, i_empl_jb_in_tourism_change_add)




# Get assets sold small multiples
workers <- workers %>% mutate(d_sold_personal_assets = ifelse((i_econ_covid_effects__5 == 1 ), T, F ))
workers <- workers %>% mutate(d_sold_professional_assets = ifelse(( i_econ_covid_effects__6 == 1), T, F ))
workers <- workers %>% mutate(d_sold_land_property = ifelse((i_econ_covid_effects__7 == 1), T, F ))
SET3 <- c("d_sold_personal_assets","d_sold_professional_assets","d_sold_land_property")
RPRT.SaveChartData(workers, SET3, "SoldStuffMultiples")

# # Get detailed list of assests sold
# workers <- workers %>%  mutate(d_lost_land = ifelse((p_econ_hhd_items_pre_covid__1 == 1 & p_econ_hhd_items_post_covid__1 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_tv = ifelse((p_econ_hhd_items_pre_covid__2 == 1 & p_econ_hhd_items_post_covid__2 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_cabletv = ifelse((p_econ_hhd_items_pre_covid__3 == 1 & p_econ_hhd_items_post_covid__3 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_computer = ifelse((p_econ_hhd_items_pre_covid__4 == 1 & p_econ_hhd_items_post_covid__4 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_internet = ifelse((p_econ_hhd_items_pre_covid__5 == 1 & p_econ_hhd_items_post_covid__5 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_phone = ifelse((p_econ_hhd_items_pre_covid__6 == 1 & p_econ_hhd_items_post_covid__6 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_mobile = ifelse((p_econ_hhd_items_pre_covid__7 == 1 & p_econ_hhd_items_post_covid__7 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_fridge = ifelse((p_econ_hhd_items_pre_covid__8 == 1 & p_econ_hhd_items_post_covid__8 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_2whlr = ifelse((p_econ_hhd_items_pre_covid__9 == 1 & p_econ_hhd_items_post_covid__9 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_4whlr_pri = ifelse((p_econ_hhd_items_pre_covid__10 == 1 & p_econ_hhd_items_post_covid__10 == 0), T, F ))
# workers <- workers %>%  mutate(d_lost_4whlr_pub = ifelse((p_econ_hhd_items_pre_covid__11 == 1 & p_econ_hhd_items_post_covid__11 == 0), T, F ))
# 
# 
# SET5 <- c("d_lost_land","d_lost_tv","d_lost_cabletv", "d_lost_computer", 
#           "d_lost_internet", "d_lost_phone", "d_lost_mobile", "d_lost_fridge", 
#           "d_lost_2whlr", "d_lost_4whlr_pri", "d_lost_4whlr_pub")
# 
# SaveChartData(workers, SET5, "SoldStuffDetailMultiples")


# Get borrowing split
workers <- workers %>% mutate(d_borrowing = ifelse((i_econ_covid_effects__1 == 1 | i_econ_covid_effects__2 == 1), T, F ))
workers <- workers %>% mutate(d_borrowing_friends_only = ifelse((i_econ_covid_effects__1 != 1 & i_econ_covid_effects__2 == 1), T, F ))
workers <- workers %>% mutate(d_borrowing_fin_only = ifelse((i_econ_covid_effects__1 == 1 & i_econ_covid_effects__2 != 1), T, F ))
workers <- workers %>% mutate(d_borrowing_mixed = ifelse((i_econ_covid_effects__1 == 1 & i_econ_covid_effects__2 == 1), T, F ))
SET4 <- c("d_borrowing","d_borrowing_friends_only","d_borrowing_fin_only", "d_borrowing_mixed")
RPRT.SaveChartData(workers, SET4, "BorrowingSplit")



# Get loan exposure dist
RPRT.SaveDistData(workers, "p_econ_outstndng_loans_self", "LoanExposure")



# Get next six months challenges (rank 1) dist
workers <- RPRT.CorrectBiggestPriorityVar(workers, "o_impct_to_self_nxt_6_mnths", "o_impct_to_self_nxt_6_mnths_rnk_1")
RPRT.SaveDistData(workers, "o_impct_to_self_nxt_6_mnths_rnk_1", "NextSixMonthsChallengesRnk1Dist")

# Get next six months challenges multiples
workers <- workers %>% mutate(d_difficulty_paying_rent = ifelse((o_impct_to_self_nxt_6_mnths__1 == 1 | o_impct_to_self_nxt_6_mnths__2 == 1), T, F ))
workers <- workers %>% mutate(d_difficulty_to_pay_for_health = ifelse((o_impct_to_self_nxt_6_mnths__3 == 1), T, F ))
workers <- workers %>% mutate(d_difficulty_to_pay_for_education = ifelse((o_impct_to_self_nxt_6_mnths__4 == 1), T, F ))
workers <- workers %>% mutate(d_difficulty_to_pay_for_food = ifelse((o_impct_to_self_nxt_6_mnths__5 == 1), T, F ))
workers <- workers %>% mutate(d_difficulty_borrow_cash = ifelse((o_impct_to_self_nxt_6_mnths__6 == 1), T, F ))
workers <- workers %>% mutate(d_difficulty_repay_loans = ifelse((o_impct_to_self_nxt_6_mnths__7 == 1), T, F ))

SET5 <- c(
  "d_difficulty_paying_rent",
  "d_difficulty_repay_loans",
  "d_difficulty_to_pay_for_food",
  "d_difficulty_to_pay_for_health",
  "d_difficulty_to_pay_for_education",
  "d_difficulty_borrow_cash" 
  )

RPRT.SaveChartData(workers, SET5, "NextSixMonthsChallengesMultiples")





# Worker movement and skills loss
# workers <- workers %>% mutate(d_moved = ifelse(i_lvlhd_domicile_chng_self != 4, T, F))
# workers <- workers %>% mutate(d_not_moved = ifelse(d_moved != T, T, F))
# 
# SET1 <- c("d_is_worker","d_moved","d_not_moved")
# RPRT.SaveChartData(workers, SET1, "MovementSplit")
# 
# 
# workers <- workers %>% mutate(d_moved_temp = ifelse(((i_lvlhd_domicile_chng_self == 1)), T, F))
# workers <- workers %>% mutate(d_moved_permanent = ifelse(((i_lvlhd_domicile_chng_self == 2 | i_lvlhd_domicile_chng_self == 3)), T, F))
# workers <- workers %>% mutate(d_moved_permanent_neighbourhood = ifelse(((i_lvlhd_domicile_chng_self == 2 )), T, F))
# workers <- workers %>% mutate(d_moved_permanent_city = ifelse(((i_lvlhd_domicile_chng_self == 3 )), T, F))
# workers <- workers %>% mutate(d_moved_never = ifelse(((i_lvlhd_domicile_chng_self == 4)), T, F))
# 
# SET1 <- c("d_moved","d_moved_temp","d_moved_permanent")
# SaveChartData(workers, SET1, "TempPermMigrationSplit")
# 
# 
# 
# workers <- workers %>% mutate(d_lost_job = ifelse((i_empl_covid_effects__1 == 1 | i_empl_covid_effects__2 == 1), T, F ))
# workers <- workers %>% mutate(d_lost_job_but_working_now = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status == 1 | i_empl_jb_prsnt_status == 2)), T, F ))
# workers <- workers %>% mutate(d_lost_job_still_no_work = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status != 1 & i_empl_jb_prsnt_status != 2)), T, F ))
# workers <- workers %>% mutate(d_stayed_employed = ifelse((i_empl_covid_effects__1 != 1 & i_empl_covid_effects__2 != 1), T, F ))
# workers <- workers %>% mutate(d_presently_employed = ifelse((d_stayed_employed == T | d_lost_job_but_working_now == T), T, F ))
# 
# workers <- workers %>% mutate(d_moved_temp_presently_employed = ifelse((d_moved_temp == T & d_presently_employed == T), T, F ))
# workers <- workers %>% mutate(d_moved_temp_presently_not_employed = ifelse((d_moved_temp == T & d_presently_employed != T), T, F ))
# SET1 <- c("d_moved_temp","d_moved_temp_presently_employed","d_moved_temp_presently_not_employed")
# SaveChartData(workers, SET1, "TempEmployedSplit")
# 
# workers <- workers %>% mutate(d_moved_permanent_presently_employed = ifelse((d_moved_permanent == T & d_presently_employed == T), T, F ))
# workers <- workers %>% mutate(d_moved_permanent_presently_not_employed = ifelse((d_moved_permanent == T & d_presently_employed != T), T, F ))
# SET1 <- c("d_moved_permanent","d_moved_permanent_presently_employed","d_moved_permanent_presently_not_employed")
# SaveChartData(workers, SET1, "PermEmployedSplit")


workers <- workers %>% mutate(d_switched_occupation = ifelse((i_empl_jb_in_tourism_change == 1 | i_empl_jb_in_tourism_change_add == 1), T, F )) %>% mutate(d_switched_occupation = ifelse(is.na(d_switched_occupation), F, d_switched_occupation))
workers <- workers %>% mutate(d_prsntly_empl_switched_occupation =  ifelse((d_switched_occupation == T & d_presently_employed == T), T, F))
workers <- workers %>% mutate(d_prsntly_empl_didnt_switch =  ifelse((d_switched_occupation == F  & d_presently_employed == T ), T, F))
SET1 <- c("d_presently_employed","d_prsntly_empl_switched_occupation","d_prsntly_empl_didnt_switch")
RPRT.SaveChartData(workers, SET1, "PresentlyEmployedJobSwitchSplit")


#Psych



workers <- workers %>% mutate(d_psychologically_affected = ifelse((i_mental_hlth_think == 2 | i_mental_hlth_overconcerned == 2 | i_mental_hlth_neg_think == 2 | i_mental_hlth_blame == 2 | i_mental_hlth_social== 2 |  i_mental_hlth_detached == 2 | i_mental_hlth_fml ==2), T, F )) 

RPRT.SaveDistData(workers, "d_psychologically_affected", "PsychologicallyAffectedDist")

workers$i_mental_hlth_blame <- ifelse(workers$i_mental_hlth_blame == 2, T, F)
workers$i_mental_hlth_think <- ifelse(workers$i_mental_hlth_think == 2, T, F)
workers$i_mental_hlth_detached <- ifelse(workers$i_mental_hlth_detached == 2, T, F)
workers$i_mental_hlth_fml <- ifelse(workers$i_mental_hlth_fml == 2, T, F)
workers$i_mental_hlth_neg_think <- ifelse(workers$i_mental_hlth_neg_think == 2, T, F)
workers$i_mental_hlth_social <- ifelse(workers$i_mental_hlth_social == 2, T, F)
workers$i_mental_hlth_overconcerned <- ifelse(workers$i_mental_hlth_overconcerned == 2, T, F)

SET1 <- c(
  "i_mental_hlth_think",
  "i_mental_hlth_social",
  "i_mental_hlth_detached",
  "i_mental_hlth_neg_think",
  "i_mental_hlth_fml", 
  "i_mental_hlth_overconcerned",
  "i_mental_hlth_blame"
  
)


RPRT.SaveChartData(workers, SET1, "PsychosocialEffectsMultiples")


RPRT.SaveDistData(workers, "i_mental_hlth_therapy", "CounselingDist")







# workers <- workers %>% mutate(d_still_working = ifelse((i_empl_jb_prsnt_status == 1 | i_empl_jb_prsnt_status == 2), T, F ))
# workers <- workers %>% mutate(d_presently_unemployed = ifelse((i_empl_jb_prsnt_status == 3 | i_empl_jb_prsnt_status == 4), T, F ))
# 
# workers <- workers %>% mutate(d_changed_location_self = ifelse((i_lvlhd_domicile_chng_self == 1 | i_lvlhd_domicile_chng_self == 2 | i_lvlhd_domicile_chng_self == "3"), T, F ))                              
# workers <- workers %>% mutate(d_changed_location_fml = ifelse((i_lvlhd_domicile_chng_fml == 2 | i_lvlhd_domicile_chng_fml == 3), T, F ))
# workers <- workers %>% mutate(d_had_covid_self = ifelse((i_hlth_covid_infectn_self == 1), T, F ))
# 
# workers <- workers %>% mutate(d_worked_in_low_salary = ifelse((i_empl_covid_effects__4 == 1), T, F ))
# workers <- workers %>% mutate(d_stayed_employed = ifelse((i_empl_covid_effects__1 != 1 & i_empl_covid_effects__2 != 1), T, F ))
# workers <- workers %>% mutate(d_employed_but_in_low_salary = ifelse(((i_empl_covid_effects__4 == 1) & (i_empl_covid_effects__1 != 1) & (i_empl_covid_effects__2 != 1)), T, F ))
# workers <- workers %>% mutate(d_employed_kept_salary = ifelse(((i_empl_covid_effects__4 != 1) & (i_empl_covid_effects__1 != 1) & (i_empl_covid_effects__2 != 1)), T, F ))
# 
# workers <- workers %>% mutate(d_direct_fin_impact = ifelse((d_worked_in_low_salary == T | d_lost_job == T), T, F ))
# workers <- workers %>% mutate(d_rotational_employment = ifelse((i_empl_covid_effects__5 == 1), T, F ))
# workers <- workers %>% mutate(d_took_loan = ifelse((i_econ_covid_effects__1 == 1 | i_econ_covid_effects__2 == 1), T, F ))
# workers <- workers %>% mutate(d_sold_assets = ifelse((i_econ_covid_effects__5 == 1 | i_econ_covid_effects__6 == 1), T, F ))
# workers <- workers %>% mutate(d_sold_land_property = ifelse((i_econ_covid_effects__7 == 1), T, F ))
# workers <- workers %>% mutate(d_effect_to_family = ifelse((i_econ_covid_effects__3 == 1 | i_econ_covid_effects__4 == 1), T, F ))
# workers <- workers %>% mutate(d_income_loss_50_or_more = ifelse((i_econ_incm_chng_self == 1 | i_econ_incm_chng_self == 3 | i_econ_incm_chng_self == 4), T, F ))
# workers <- workers %>% mutate(d_saving_loss_50_or_more = ifelse((p_econ_self_savings_chng_today_v_19 == 3 | p_econ_self_savings_chng_today_v_19 == 4 | i_econ_incm_chng_self == 5), T, F ))
# 
# workers <- workers %>% mutate(d_has_outstanding_loan = ifelse((p_econ_outstndng_loans_self == 1), T, F ))
# 
# workers <- workers %>% mutate(d_has_vaccinated_self = ifelse((p_hlth_vaccinated_self == 1), T, F ))
# workers <- workers %>% mutate(d_has_hhs_self = ifelse((p_hlth_received_hhs_training_self == 1), T, F ))
# 
# summary(workers[345:362])
# 
# 
# getPercentages <- function(VARS) {
#   
# }
# 
# ADDITIONAL_SS_VARS <- c("d_still_working", 
#                         "d_presently_unemployed",
#                         "d_stayed_employed",
#                         "d_changed_location_self", 
#                         "d_changed_location_fml", 
#                         "d_had_covid_self",
#                         "d_lost_job",
#                         "d_worked_in_low_salary", 
#                         "d_direct_fin_impact", 
#                         "d_rotational_employment",
#                         "d_took_loan", 
#                         "d_sold_assets", 
#                         "d_sold_land_property",
#                         "d_effect_to_family",
#                         "d_income_loss_50_or_more", 
#                         "d_has_outstanding_loan", 
#                         "d_has_vaccinated_self", 
#                         "d_has_hhs_self", "d_employed_but_in_low_salary" )
# 
# 
# ADDITIONAL_SS_VARS_SET1 <- c("d_lost_job",
#                         "d_presently_unemployed",
#                         "d_employed_but_in_low_salary", 
#                         "d_rotational_employment"
#                          )
# 
# 
# ADDITIONAL_SS_VARS_SET2 <- c("d_stayed_employed",
#                              "d_employed_kept_salary",
#                              "d_employed_but_in_low_salary"
#                              
# )
# 
# 
# univariateStatsForSS <- UNI.GetCountsAndProportionsSS(workers, ADDITIONAL_SS_VARS_SET2) 
# 
# forSmallMultipleGraph <- univariateStatsForSS %>% 
#   filter(value!=FALSE) %>% 
#   select(variable, perc_of_total) %>%
#   rename(label=variable, value=perc_of_total)
# 
# IO.SaveJson(forSmallMultipleGraph, "EconStats", JSON_EXPORT_PATH)
# 
# 
