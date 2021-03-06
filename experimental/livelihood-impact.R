# Imports
source("~/projects/c2m2/kathmandu-survey/utils/functions.R")
source("~/projects/c2m2/kathmandu-survey/utils/constants.R")

# Parameters
survey_data_path <- paste0(ROOT_URL, "raw/data/workers_data_20210429.xlsx")

# Survey data
workers_data <- IO.XlsSheetToDF(excel_sheets(survey_data_path)[1], survey_data_path)

# Remove rows with NAs
workers <- workers_data %>% filter(!is.na(m_gender))


# Functions
SaveChartData <- function(DF, VARS, FILE) {
  final <- UNI.GetCountsAndProportionsSS(DF, VARS) 
  final <- final %>% 
    filter(value!=FALSE) %>% 
    select(variable, perc_of_total) %>%
    rename(label=variable, value=perc_of_total)
  IO.SaveJson(final, FILE, JSON_EXPORT_PATH)
  return(final)
}

SaveDistData <- function(DF, VAR, FILE) {
  dist <- UNI.GetCountsAndProportionsSS(DF, c(VAR))
  path <- paste0(ROOT_URL, "misc/mapping.xlsx")
  mapping <- IO.XlsSheetToDF(excel_sheets(path)[1], path) %>% select(variable, value, label_ne, label_en)
  dist_w_labels <- left_join(dist, mapping)
  IO.SaveJson(dist_w_labels, FILE, JSON_EXPORT_PATH)
  return(dist_w_labels)
}

# Get multiples by sector
workers <- workers %>% mutate(d_occptn_exp_selling = ifelse((b_empl_occpatn_pre_covid__2 == 1 | b_empl_occpatn_pre_covid__3 == 1 | b_empl_occpatn_pre_covid__4 == 1 | b_empl_occpatn_pre_covid__5 == 1 ), T, F ) )
workers <- workers %>% mutate(d_occptn_travel = ifelse((b_empl_occpatn_pre_covid__6 == 1 | b_empl_occpatn_pre_covid__7 == 1 | b_empl_occpatn_pre_covid__8 == 1 | b_empl_occpatn_pre_covid__9 == 1 | b_empl_occpatn_pre_covid__15 == 1), T, F ) )
workers <- workers %>% mutate(d_occptn_accomodation = ifelse((b_empl_occpatn_pre_covid__10 == 1 | b_empl_occpatn_pre_covid__11 == 1 | b_empl_occpatn_pre_covid__12 == 1 | b_empl_occpatn_pre_covid__13 == 1 | b_empl_occpatn_pre_covid__14 == 1), T, F ) )
workers <- workers %>% mutate(d_occptn_othr = ifelse((b_empl_occpatn_pre_covid__16 == 1), T, F ) )

SET1 <- c("d_occptn_exp_selling","d_occptn_accomodation","d_occptn_travel", "d_occptn_othr")
SaveChartData(workers, SET1, "SectoralBreakdownMultiple")


# Explore sector 1
workers <- workers %>% mutate(d_stayed_employed = ifelse((i_empl_covid_effects__1 != 1 & i_empl_covid_effects__2 != 1), T, F ))
workers <- workers %>% mutate(d_employed_but_in_low_salary = ifelse(((i_empl_covid_effects__4 == 1) & (i_empl_covid_effects__1 != 1) & (i_empl_covid_effects__2 != 1)), T, F ))
workers <- workers %>% mutate(d_employed_kept_salary = ifelse(((i_empl_covid_effects__4 != 1) & (i_empl_covid_effects__1 != 1) & (i_empl_covid_effects__2 != 1)), T, F ))
workers <- workers %>% mutate(d_lost_job = ifelse((i_empl_covid_effects__1 == 1 | i_empl_covid_effects__2 == 1), T, F ))
workers <- workers %>% mutate(d_lost_job_but_working_now = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status == 1 | i_empl_jb_prsnt_status == 2)), T, F ))
workers <- workers %>% mutate(d_lost_job_still_no_work = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status != 1 & i_empl_jb_prsnt_status != 2)), T, F ))
workers <- workers %>% mutate(d_presently_employed = ifelse((d_stayed_employed == T | d_lost_job_but_working_now == T), T, F ))



# Sector 1: Employment status at present.
workers <- workers %>% mutate(d_presently_employed_1 =  ifelse((d_presently_employed == T & d_occptn_exp_selling==T), T, F))
workers <- workers %>% mutate(d_presently_unemployed_1 =  ifelse((d_lost_job_still_no_work == T & d_occptn_exp_selling==T), T, F))
SET1 <- c("d_occptn_exp_selling","d_presently_employed_1","d_presently_unemployed_1")
SaveChartData(workers, SET1, "ExpSellUnemploymentSplit")


# Sector 1: Switching occupation
workers <- workers %>% mutate(d_switched_occupation = ifelse((i_empl_jb_in_tourism_change == 1 | i_empl_jb_in_tourism_change_add == 1), T, F )) %>% mutate(d_switched_occupation = ifelse(is.na(d_switched_occupation), F, d_switched_occupation))
workers <- workers %>% mutate(d_prsntly_empl_switched_occupation_1 =  ifelse((d_switched_occupation == T & d_occptn_exp_selling==T & d_presently_employed == T), T, F))
workers <- workers %>% mutate(d_prsntly_empl_didnt_switch_1 =  ifelse((d_switched_occupation == F & d_occptn_exp_selling==T & d_presently_employed == T ), T, F))
SET1 <- c("d_presently_employed_1","d_prsntly_empl_switched_occupation_1","d_prsntly_empl_didnt_switch_1")
SaveChartData(workers, SET1, "ExpSellEmployedJobChangeSplit")



# QC Needed
workers <- workers %>% mutate(d_switched_self_location_once_1 = ifelse(((i_lvlhd_domicile_chng_self == 1  | i_lvlhd_domicile_chng_self == 2 |  i_lvlhd_domicile_chng_self == 3) &  d_occptn_exp_selling==T), T, F))
workers <- workers %>% mutate(d_switched_self_location_permanently_neighbourhood_1 = ifelse(((i_lvlhd_domicile_chng_self == 2 ) &  d_occptn_exp_selling==T), T, F))
workers <- workers %>% mutate(d_switched_self_location_permanently_city_1 = ifelse(((i_lvlhd_domicile_chng_self == 3 ) &  d_occptn_exp_selling==T), T, F))
workers <- workers %>% mutate(d_switched_self_location_temp_1 = ifelse(((i_lvlhd_domicile_chng_self == 4) &  d_occptn_exp_selling==T), T, F))
workers <- workers %>% mutate(d_switched_self_location_never_1 = ifelse(((i_lvlhd_domicile_chng_self == 1) &  d_occptn_exp_selling==T), T, F))

SET1 <- c("d_occptn_exp_selling","d_switched_self_location_once_1", "d_switched_self_location_never_1")
SaveChartData(workers, SET1, "ExpSellMoveNoMoveSplit")



SET1 <- c("d_switched_self_location_once_1","d_switched_self_location_permanently_neighbourhood_1", "d_switched_self_location_permanently_city_1","d_switched_self_location_temp_1")
SaveChartData(workers, SET1, "ExpSellMoveNatureSplit")


# Sector 1: switching location





workers$d_prsntly_empl_switched_occupation_same_sectr



ifelse((workers$i_empl_jb_in_tourism_change==2 | workers$i_empl_jb_in_tourism_change_add == 2), T,F)



# Sector 1: Impact on family members
workers <- workers %>% mutate(d_had_to_stop_someones_ed= ifelse(i_econ_covid_effects__3 == 1, T, F))
workers <- workers %>% mutate(d_had_to_stop_someones_healthservices= ifelse(i_econ_covid_effects__4 == 1, T, F))
workers <- workers %>% mutate(d_cldnt_rnew_licens= ifelse(i_empl_covid_effects__6 == 1, T, F))






workers <- workers %>%  mutate(d_presently_employed_switched_profession_1 =  ifelse((d_presently_employed == T & d_occptn_exp_selling==T), T, F))



# how are they maintaining their livelihoods?




# Get the distribution of respondents by the number of dependents before the pandemic - not very useful
SaveDistData(workers, "p_lvlhd_num_depndnt_fml_membrs_pre_covid", "NumberOfDependentsPreCovidDist")
SaveDistData(workers, "p_lvlhd_num_depndnt_fml_membrs_post_covid", "NumberOfDependentsPostCovidDist")
SaveDistData(workers, "p_lvlhd_num_depndnt_need_fml_membrs_post_covid", "NumberOfDependentsNeedMetPostCovidDist")



# Source of income
# Assets
# Savings




# Get the percentage of people whose dependency burden has increased post pandemic - also not very useful 
workers <- workers %>% mutate(d_has_dependents_decreased = ifelse((as.numeric(p_lvlhd_num_depndnt_fml_membrs_post_covid) < as.numeric(p_lvlhd_num_depndnt_fml_membrs_pre_covid)), T, F))
workers <- workers %>% mutate(d_has_dependents_increased = ifelse((as.numeric(p_lvlhd_num_depndnt_fml_membrs_post_covid) > as.numeric(p_lvlhd_num_depndnt_fml_membrs_pre_covid)), T, F))
workers <- workers %>% mutate(d_has_dependents_styd_same = ifelse((as.numeric(p_lvlhd_num_depndnt_fml_membrs_post_covid) == as.numeric(p_lvlhd_num_depndnt_fml_membrs_pre_covid)), T, F))

SET1 <- c("d_has_dependents_decreased","d_has_dependents_styd_same","d_has_dependents_increased")
SaveChartData(workers, SET1, "DependentsChangeSmallMultiples")

workers <- workers %>% mutate(d_had_to_move_family= ifelse(i_lvlhd_domicile_chng_fml == 2 | i_lvlhd_domicile_chng_fml == 3, T, F))
workers <- workers %>% mutate(d_had_to_move_family_new_place= ifelse(i_lvlhd_domicile_chng_fml == 3, T, F))
workers <- workers %>% mutate(d_had_to_move_family_new_neighbourhood= ifelse(i_lvlhd_domicile_chng_fml == 2, T, F))


workers <- workers %>% mutate(d_had_to_move_family= ifelse(i_lvlhd_domicile_chng_fml == 2 | i_lvlhd_domicile_chng_fml == 3, T, F))
workers <- workers %>% mutate(d_had_to_move_family_new_place= ifelse(i_lvlhd_domicile_chng_fml == 3, T, F))
workers <- workers %>% mutate(d_had_to_move_family_new_neighbourhood= ifelse(i_lvlhd_domicile_chng_fml == 2, T, F))


workers <- workers %>% mutate(d_had_to_stop_someones_ed= ifelse(i_econ_covid_effects__3 == 1, T, F))
workers <- workers %>% mutate(d_had_to_stop_someones_healthservices= ifelse(i_econ_covid_effects__4 == 1, T, F))
workers <- workers %>% mutate(d_cldnt_rnew_licens= ifelse(i_empl_covid_effects__6 == 1, T, F))


summary(workers$d_cldnt_rnew_licens)


# Lost jobs split
workers <- workers %>% mutate(d_lost_job = ifelse((i_empl_covid_effects__1 == 1 | i_empl_covid_effects__2 == 1), T, F ))
workers <- workers %>% mutate(d_lost_job_but_working_now = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status == 1 | i_empl_jb_prsnt_status == 2)), T, F ))
workers <- workers %>% mutate(d_lost_job_still_no_work = ifelse((d_lost_job == T & (i_empl_jb_prsnt_status != 1 & i_empl_jb_prsnt_status != 2)), T, F ))

SET1 <- c("d_lost_job","d_lost_job_but_working_now","d_lost_job_still_no_work")
SaveChartData(workers, SET1, "LostJobsSplit")



# Lost job havent found work distribution by sector
workers <- workers %>% mutate(d_occptn_travel_and_tour_guides = ifelse((b_empl_occpatn_pre_covid__2 == 1 | b_empl_occpatn_pre_covid__3 == 1 | b_empl_occpatn_pre_covid__4 == 1 | b_empl_occpatn_pre_covid__5 == 1 ), T, F ) )
workers <- workers %>% mutate(d_occptn_travel_and_tour_other = ifelse((b_empl_occpatn_pre_covid__6 == 1 | b_empl_occpatn_pre_covid__7 == 1 | b_empl_occpatn_pre_covid__8 == 1 | b_empl_occpatn_pre_covid__9 == 1 | b_empl_occpatn_pre_covid__15 == 1), T, F ) )
workers <- workers %>% mutate(d_occptn_accomodation_hotel_food = ifelse((b_empl_occpatn_pre_covid__10 == 1 | b_empl_occpatn_pre_covid__11 == 1 | b_empl_occpatn_pre_covid__12 == 1 | b_empl_occpatn_pre_covid__13 == 1 | b_empl_occpatn_pre_covid__14 == 1), T, F ) )
workers <- workers %>% mutate(d_occptn_othr = ifelse((b_empl_occpatn_pre_covid__16 == 1), T, F ) )


workersss <- workers %>% filter(d_lost_job_still_no_work == T)
SaveDistDataMS(workersss, "d_occptn", "LostJobSectorWiseDist")



# Did you lose job once during the pandemic?

workers <- workers %>% mutate(d_no_work_ttg = ifelse((d_lost_job_still_no_work == T & (d_occptn_travel_and_tour_guides=T)), T, F ))
workers <- workers %>% mutate(d_no_work_tto = ifelse((d_lost_job_still_no_work == T & (d_occptn_travel_and_tour_other=T)), T, F ))
workers <- workers %>% mutate(d_no_work_acc = ifelse((d_lost_job_still_no_work == T & (d_occptn_accomodation_hotel_food=T)), T, F ))
workers <- workers %>% mutate(d_no_work_othr = ifelse((d_lost_job_still_no_work == T & (d_occptn_othr=T)), T, F ))

SET1 <- c("d_lost_job_still_no_work","d_no_work_ttg","d_no_work_ttg", "d_no_work_tto","d_no_work_acc", "d_no_work_othr")
SaveChartData(workers, SET1, "OccupationSectorSplit")
