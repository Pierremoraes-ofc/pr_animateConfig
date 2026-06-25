Config = Config or {}

Config.Language = "ptBr"
Config.Debug = true
Config.DebugMaxEntries = 10
Config.Command = "animconfig"
Config.TestCommand = "pranimtest"
Config.TestStopCommand = "pranimstop"
Config.CloseKey = 177 -- Backspace

Config.Camera = {
    enabled = true,
    useRightMouse = true,
}

Config.Preview = {
    cloneDistance = 1.25,
}

Config.DefaultAnimation = {
    dict = "mp_player_intdrink",
    name = "loop_bottle",
    flag = 49,
    blendIn = 8.0,
    blendOut = -8.0,
    duration = -1,
    playbackRate = 1.0,
}

Config.DefaultProp = {
    model = "prop_ld_flow_bottle",
    boneId = 57005,
    rotationOrder = 2,
    offset = { x = 0.12, y = 0.02, z = -0.02 },
    rotation = { x = -80.0, y = 0.0, z = 10.0 },
}

Config.NudgeSteps = {
    position = { 0.001, 0.005, 0.01, 0.05, 0.1 },
    rotation = { 0.1, 0.5, 1.0, 5.0, 15.0 },
}

Config.AnimationFlags = {
    { labelId = "loop", value = 1 },
    { labelId = "upper", value = 16 },
    { labelId = "move", value = 32 },
    { labelId = "stay", value = 49 },
    { labelId = "freeze", value = 50 },
}

Config.Animations = {
    {
        labelId = "AirportBag",
        dict = "anim@heists@narcotics@trash",
        name = "idle",
        flag = 49,
    },
    {
        labelId = "Apple",
        dict = "mp_player_inteat@burger",
        name = "mp_player_int_eat_burger",
        flag = 32,
    },
    {
        labelId = "Axe",
        dict = "rcmnigel1d",
        name = "base_club_shoulder",
        flag = 49,
    },
    {
        labelId = "AxeGroundImpact",
        dict = "melee@large_wpn@streamed_core",
        name = "ground_attack_on_spot",
        flag = 1,
    },
    {
        labelId = "BBQFemale",
        dict = "amb@prop_human_bbq@male@idle_a",
        name = "idle_b",
        flag = 49,
    },
    {
        labelId = "Backpack",
        dict = "move_p_m_zero_rucksack",
        name = "nill",
        flag = 49,
    },
    {
        labelId = "Basketball",
        dict = "anim@male_bskball_hold",
        name = "bskball_hold_clip",
        flag = 49,
    },
    {
        labelId = "Basketball2",
        dict = "anim@male_bskball_photo_pose",
        name = "photo_pose_clip",
        flag = 49,
    },
    {
        labelId = "Basketball3",
        dict = "mx@pose2",
        name = "mx_clippose2",
        flag = 1,
    },
    {
        labelId = "Basketball4",
        dict = "anim@male_basketball_03",
        name = "m_basketball_03_clip",
        flag = 49,
    },
    {
        labelId = "BeachBag",
        dict = "move_weapon@jerrycan@generic",
        name = "idle",
        flag = 49,
    },
    {
        labelId = "BeachFloatie",
        dict = "beachanims@free",
        name = "beachanim_clip",
        flag = 49,
    },
    {
        labelId = "Beans",
        dict = "anim@scripted@island@special_peds@pavel@hs4_pavel_ig5_caviar_p1",
        name = "base_idle",
        flag = 49,
    },
    {
        labelId = "Beer2",
        dict = "amb@world_human_drinking@beer@male@idle_a",
        name = "idle_c",
        flag = 49,
    },
    {
        labelId = "BeerFemale",
        dict = "amb@world_human_drinking@beer@female@idle_a",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "Beg",
        dict = "amb@world_human_bum_freeway@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Binoculars",
        dict = "amb@world_human_binoculars@male@idle_b",
        name = "idle_f",
        flag = 49,
    },
    {
        labelId = "Binoculars2",
        dict = "amb@world_human_binoculars@male@idle_a",
        name = "idle_c",
        flag = 49,
    },
    {
        labelId = "Bonesaw",
        dict = "anim@heists@humane_labs@finale@keycards",
        name = "ped_a_enter_loop",
        flag = 32,
    },
    {
        labelId = "Bong",
        dict = "anim@safehouse@bong",
        name = "bong_stage3",
        flag = 49,
    },
    {
        labelId = "BongoDrums",
        dict = "amb@world_human_musician@bongos@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Boombox2",
        dict = "molly@boombox1",
        name = "boombox1_clip",
        flag = 49,
    },
    {
        labelId = "Bouquet",
        dict = "impexp_int-0",
        name = "mp_m_waremech_01_dual-0",
        flag = 49,
    },
    {
        labelId = "Box",
        dict = "anim@heists@box_carry@",
        name = "idle",
        flag = 49,
    },
    {
        labelId = "Briefcase2",
        dict = "missheistdocksprep1hold_cellphone",
        name = "static",
        flag = 49,
    },
    {
        labelId = "Broom",
        dict = "anim@amb@drug_field_workers@rake@male_a@base",
        name = "base",
        flag = 1,
    },
    {
        labelId = "Broom2",
        dict = "anim@amb@drug_field_workers@rake@male_a@idles",
        name = "idle_b",
        flag = 1,
    },
    {
        labelId = "Broom3",
        dict = "anim@amb@drug_field_workers@rake@male_b@base",
        name = "base",
        flag = 1,
    },
    {
        labelId = "Broom4",
        dict = "anim@amb@drug_field_workers@rake@male_b@idles",
        name = "idle_d",
        flag = 1,
    },
    {
        labelId = "BurgerShotFries",
        dict = "mp_player_inteat@burger",
        name = "mp_player_int_eat_burger_fp",
        flag = 49,
    },
    {
        labelId = "Camera",
        dict = "amb@world_human_paparazzi@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Camera2",
        dict = "cellphone@female",
        name = "cellphone_text_read_base_cover_low",
        flag = 32,
    },
    {
        labelId = "Candy",
        dict = "mp_player_inteat@pnq",
        name = "loop",
        flag = 32,
    },
    {
        labelId = "ChampagneSpray",
        dict = "anim@mp_player_intupperspray_champagne",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "ChampagneWaiter",
        dict = "anim@move_f@waitress",
        name = "idle",
        flag = 49,
    },
    {
        labelId = "CircularSaw",
        dict = "anim@heists@fleeca_bank@drilling",
        name = "drill_straight_fail",
        flag = 49,
    },
    {
        labelId = "Clean",
        dict = "timetable@floyd@clean_kitchen@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Clean2",
        dict = "amb@world_human_maid_clean@",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Clipboard",
        dict = "missfam4",
        name = "base",
        flag = 49,
    },
    {
        labelId = "CoffeeIdle",
        dict = "amb@world_human_drinking@coffee@male@idle_a",
        name = "idle_c",
        flag = 49,
    },
    {
        labelId = "ConeHead",
        dict = "move_m@drunk@verydrunk_idles@",
        name = "fidget_07",
        flag = 49,
    },
    {
        labelId = "CopWand",
        dict = "amb@world_human_car_park_attendant@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "CrackHead",
        dict = "special_ped@zombie@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "CranialSaw",
        dict = "anim@heists@fleeca_bank@drilling",
        name = "drill_straight_end",
        flag = 49,
    },
    {
        labelId = "Dig",
        dict = "random@burial",
        name = "a_burial",
        flag = 1,
    },
    {
        labelId = "Digiscan1",
        dict = "weapons@misc@digi_scanner",
        name = "aim_med_loop",
        flag = 49,
    },
    {
        labelId = "Digiscan2",
        dict = "weapons@misc@digi_scanner",
        name = "aim_low_loop",
        flag = 49,
    },
    {
        labelId = "Digiscan3",
        dict = "weapons@misc@digi_scanner",
        name = "aim_high_loop",
        flag = 49,
    },
    {
        labelId = "DrinkBottle",
        dict = "mp_player_intdrink",
        name = "loop_bottle",
        flag = 49,
    },
    {
        labelId = "Fishing1",
        dict = "amb@world_human_stand_fishing@idle_a",
        name = "idle_a",
        flag = 1,
    },
    {
        labelId = "Fishing2",
        dict = "amb@world_human_stand_fishing@idle_a",
        name = "idle_b",
        flag = 1,
    },
    {
        labelId = "Fishing3",
        dict = "amb@world_human_stand_fishing@idle_a",
        name = "idle_c",
        flag = 1,
    },
    {
        labelId = "Fuel",
        dict = "weapons@misc@jerrycan@",
        name = "fire",
        flag = 49,
    },
    {
        labelId = "Fuel2Carry",
        dict = "weapons@misc@jerrycan@franklin",
        name = "idle",
        flag = 49,
    },
    {
        labelId = "Gamer",
        dict = "playing@with_controller",
        name = "base",
        flag = 1,
    },
    {
        labelId = "GarbageBag",
        dict = "missfbi4prepp1",
        name = "_idle_garbage_man",
        flag = 49,
    },
    {
        labelId = "Gift",
        dict = "bz@give_love@anim",
        name = "bz_give",
        flag = 49,
    },
    {
        labelId = "GolfSwing",
        dict = "rcmnigel1d",
        name = "swing_a_mark",
        flag = 1,
    },
    {
        labelId = "Guitar",
        dict = "amb@world_human_musician@guitar@male@idle_a",
        name = "idle_b",
        flag = 49,
    },
    {
        labelId = "Guitar2",
        dict = "switch@trevor@guitar_beatdown",
        name = "001370_02_trvs_8_guitar_beatdown_idle_busker",
        flag = 49,
    },
    {
        labelId = "Guitar3",
        dict = "misssnowie@gatlax",
        name = "base",
        flag = 1,
    },
    {
        labelId = "GuitarBack",
        dict = "amb@bagels@male@walking@",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "Hammer",
        dict = "amb@world_human_hammering@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Hitchhike",
        dict = "random@hitch_lift",
        name = "idle_f",
        flag = 49,
    },
    {
        labelId = "HumpBear",
        dict = "timetable@trevor@skull_loving_bear",
        name = "skull_loving_bear",
        flag = 1,
    },
    {
        labelId = "IDCardDriversLicense",
        dict = "paper_1_rcm_alt1-8",
        name = "player_one_dual-8",
        flag = 32,
    },
    {
        labelId = "IDCard7Passport",
        dict = "amb@code_human_wander_clipboard@male@base",
        name = "static",
        flag = 32,
    },
    {
        labelId = "IceFishing",
        dict = "timetable@ron@ig_3_couch",
        name = "base",
        flag = 1,
    },
    {
        labelId = "JackHammer",
        dict = "amb@world_human_const_drill@male@drill@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "JerkOffFemale",
        dict = "switch@trevor@jerking_off",
        name = "trev_jerking_off_loop",
        flag = 49,
    },
    {
        labelId = "Lawnchair",
        dict = "timetable@ron@ig_5_p3",
        name = "ig_5_p3_base",
        flag = 1,
    },
    {
        labelId = "Lawnchair2",
        dict = "timetable@reunited@ig_10",
        name = "base_amanda",
        flag = 1,
    },
    {
        labelId = "LeafBlower",
        dict = "amb@world_human_gardener_leaf_blower@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "LeaningWithPhone",
        dict = "amb@world_human_leaning@male@wall@back@mobile@base",
        name = "base",
        flag = 1,
    },
    {
        labelId = "MakeItRain",
        dict = "anim@mp_player_intupperraining_cash",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "Map",
        dict = "amb@world_human_tourist_map@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Map2",
        dict = "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "Megaphone",
        dict = "molly@megaphone",
        name = "megaphone_clip",
        flag = 49,
    },
    {
        labelId = "Megaphone2",
        dict = "molly@megaphone2",
        name = "megaphone_clip",
        flag = 49,
    },
    {
        labelId = "Megaphone3",
        dict = "amb@world_human_mobile_film_shocking@female@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Mop",
        dict = "missfbi4prepp1",
        name = "idle",
        flag = 49,
    },
    {
        labelId = "Mop2",
        dict = "move_mop",
        name = "idle_scrub_small_player",
        flag = 49,
    },
    {
        labelId = "Mugshot",
        dict = "mp_character_creation@customise@male_a",
        name = "loop",
        flag = 49,
    },
    {
        labelId = "Murdered",
        dict = "dead",
        name = "dead_e",
        flag = 1,
    },
    {
        labelId = "Murdered2",
        dict = "dead",
        name = "dead_a",
        flag = 1,
    },
    {
        labelId = "Murdered3",
        dict = "dead",
        name = "dead_b",
        flag = 1,
    },
    {
        labelId = "NewsBoomMicrophone",
        dict = "missfra1",
        name = "mcs2_crew_idle_m_boom",
        flag = 49,
    },
    {
        labelId = "NewsCamera",
        dict = "missfinale_c2mcs_1",
        name = "fin_c2_mcs_1_camman",
        flag = 49,
    },
    {
        labelId = "Newspaper",
        dict = "amb@world_human_clipboard@male@idle_a",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "Notepad",
        dict = "missheistdockssetup1clipboard@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "PatrolOnFoot",
        dict = "amb@world_human_security_shine_torch@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "PatrolOnFoot2",
        dict = "amb@world_human_security_shine_torch@male@idle_b",
        name = "idle_e",
        flag = 49,
    },
    {
        labelId = "PatrolOnFoot3",
        dict = "amb@world_human_security_shine_torch@male@idle_a",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "PatrolCar",
        dict = "amb@incar@male@patrol@torch@base",
        name = "base",
        flag = 1,
    },
    {
        labelId = "PatrolCar2",
        dict = "amb@incar@male@patrol@torch@idle_b",
        name = "idle_d",
        flag = 1,
    },
    {
        labelId = "PatrolCar3",
        dict = "amb@incar@male@patrol@torch@idle_a",
        name = "idle_a",
        flag = 1,
    },
    {
        labelId = "PhoneCall",
        dict = "cellphone@",
        name = "cellphone_call_listen_base",
        flag = 49,
    },
    {
        labelId = "PhoneCall2",
        dict = "random@kidnap_girl",
        name = "ig_1_girl_on_phone_loop",
        flag = 49,
    },
    {
        labelId = "PhoneText",
        dict = "cellphone@",
        name = "cellphone_text_read_base",
        flag = 49,
    },
    {
        labelId = "PornMagazine",
        dict = "amb@world_human_clipboard@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Propose",
        dict = "ultra@propose",
        name = "propose",
        flag = 1,
    },
    {
        labelId = "Puke",
        dict = "missheistpaletoscore1leadinout",
        name = "trv_puking_leadout",
        flag = 32,
    },
    {
        labelId = "Puke2",
        dict = "anim@scripted@ulp_missions@injured_agent@",
        name = "idle",
        flag = 1,
    },
    {
        labelId = "Puke3",
        dict = "anim@scripted@freemode@throw_up_toilet@male@",
        name = "vomit",
        flag = 1,
    },
    {
        labelId = "SMS2",
        dict = "cellphone@female",
        name = "cellphone_text_read_base",
        flag = 49,
    },
    {
        labelId = "SMS3",
        dict = "cellphone@female",
        name = "cellphone_email_read_base",
        flag = 32,
    },
    {
        labelId = "SMS6",
        dict = "amb@code_human_wander_texting_fat@male@base",
        name = "static",
        flag = 32,
    },
    {
        labelId = "Selfie",
        dict = "anim@mp_player_intuppertake_selfie",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "Selfie2",
        dict = "cellphone@self@franklin@",
        name = "peace",
        flag = 49,
    },
    {
        labelId = "Selfie3",
        dict = "cellphone@self@franklin@",
        name = "west_coast",
        flag = 49,
    },
    {
        labelId = "Selfie4",
        dict = "cellphone@self@trevor@",
        name = "aggressive_finger",
        flag = 49,
    },
    {
        labelId = "Selfie5",
        dict = "cellphone@self@trevor@",
        name = "proud_finger",
        flag = 49,
    },
    {
        labelId = "Selfie6",
        dict = "cellphone@self@trevor@",
        name = "throat_slit",
        flag = 49,
    },
    {
        labelId = "Selfie7",
        dict = "cellphone@self@franklin@",
        name = "chest_bump",
        flag = 49,
    },
    {
        labelId = "Selfie8",
        dict = "mirror_selfie@peace_sign",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Selfie9",
        dict = "eagle@boypose04",
        name = "boy",
        flag = 49,
    },
    {
        labelId = "SelfieBeachBum",
        dict = "anim@female_beach_booty_selfie",
        name = "booty_selfie_clip",
        flag = 1,
    },
    {
        labelId = "SelfieCrouching",
        dict = "crouching@taking_selfie",
        name = "base",
        flag = 1,
    },
    {
        labelId = "SelfieCrouching2",
        dict = "eagle@girlphonepose13",
        name = "girl",
        flag = 1,
    },
    {
        labelId = "SelfieCrouching3",
        dict = "anim@male_insta_selfie",
        name = "insta_selfie_clip",
        flag = 1,
    },
    {
        labelId = "SelfieCrouching4",
        dict = "anim@female_selfie_risque",
        name = "selfie_risque_clip",
        flag = 1,
    },
    {
        labelId = "SelfieCute",
        dict = "anim@egirl_1foot_selfie",
        name = "1foot_selfie_clip",
        flag = 1,
    },
    {
        labelId = "SelfieCute2",
        dict = "eagle@girlphonepose21",
        name = "girl",
        flag = 1,
    },
    {
        labelId = "SelfieCute3",
        dict = "pupppy@freeselfie01",
        name = "freeselfie01",
        flag = 1,
    },
    {
        labelId = "SelfieCute4",
        dict = "pupppy@freeselfie02",
        name = "freeselfie02",
        flag = 1,
    },
    {
        labelId = "SelfieCute5",
        dict = "pupppy@freeselfie03",
        name = "freeselfie03",
        flag = 1,
    },
    {
        labelId = "SelfieCute6",
        dict = "heartselfiemirror@queensisters",
        name = "heartselfie_clip",
        flag = 1,
    },
    {
        labelId = "SelfieFloorInstagram",
        dict = "anim@selfie_floor_cute",
        name = "floor_cute_clip",
        flag = 1,
    },
    {
        labelId = "SelfieHandBag",
        dict = "anim@female_selfie_cute",
        name = "selfie_cute_clip",
        flag = 1,
    },
    {
        labelId = "SelfieMiddleFinger",
        dict = "anim@fuck_you_selfie",
        name = "fuck_you_selfie_clip",
        flag = 1,
    },
    {
        labelId = "SelfieMiddleFinger2",
        dict = "fuckyouselfie@queensisters",
        name = "mirrorselfie_clip",
        flag = 1,
    },
    {
        labelId = "SelfieMiddleFinger3",
        dict = "selfiekilye@queensisters",
        name = "kilye_clip",
        flag = 1,
    },
    {
        labelId = "SelfieSexy",
        dict = "littlespoon@selfie001",
        name = "selfie001",
        flag = 1,
    },
    {
        labelId = "SelfieSexy2",
        dict = "littlespoon@selfie002",
        name = "selfie002",
        flag = 1,
    },
    {
        labelId = "SelfieSexy3",
        dict = "littlespoon@selfie003",
        name = "selfie003",
        flag = 1,
    },
    {
        labelId = "SelfieSexy4",
        dict = "littlespoon@selfie004",
        name = "selfie004",
        flag = 1,
    },
    {
        labelId = "SelfieSexy5",
        dict = "littlespoon@selfie005",
        name = "selfie005",
        flag = 1,
    },
    {
        labelId = "SelfieThotInstagram",
        dict = "anim@sitting_thot",
        name = "sitting_thot_clip",
        flag = 1,
    },
    {
        labelId = "Shit",
        dict = "missfbi3ig_0",
        name = "shit_loop_trev",
        flag = 1,
    },
    {
        labelId = "SitTV",
        dict = "anim@heists@heist_safehouse_intro@variations@male@tv",
        name = "tv_part_one_loop",
        flag = 1,
    },
    {
        labelId = "Sitting",
        dict = "anim@amb@business@bgen@bgen_no_work@",
        name = "sit_phone_phoneputdown_idle_nowork",
        flag = 1,
    },
    {
        labelId = "Smoke2",
        dict = "amb@world_human_aa_smoke@male@idle_a",
        name = "idle_c",
        flag = 49,
    },
    {
        labelId = "Smoke3",
        dict = "amb@world_human_aa_smoke@male@idle_a",
        name = "idle_b",
        flag = 49,
    },
    {
        labelId = "Smoke4",
        dict = "amb@world_human_smoking@female@idle_a",
        name = "idle_b",
        flag = 49,
    },
    {
        labelId = "Smoking",
        dict = "amb@world_human_smoking@male@male_a@enter",
        name = "enter",
        flag = 32,
    },
    {
        labelId = "StealTV",
        dict = "beachanims@molly",
        name = "beachanim_surf_clip",
        flag = 49,
    },
    {
        labelId = "TaggingFemale1",
        dict = "anim@scripted@freemode@postertag@graffiti_spray@heeled@",
        name = "spray_can_var_01_female",
        flag = 49,
    },
    {
        labelId = "TaggingFemale2",
        dict = "anim@scripted@freemode@postertag@graffiti_spray@heeled@",
        name = "spray_can_var_02_female",
        flag = 49,
    },
    {
        labelId = "TaggingMale1",
        dict = "anim@scripted@freemode@postertag@graffiti_spray@male@",
        name = "spray_can_var_01_male",
        flag = 49,
    },
    {
        labelId = "TaggingMale2",
        dict = "anim@scripted@freemode@postertag@graffiti_spray@male@",
        name = "spray_can_var_02_male",
        flag = 49,
    },
    {
        labelId = "TaggingShakeCanFemale",
        dict = "anim@scripted@freemode@postertag@graffiti_spray@heeled@",
        name = "shake_can_female",
        flag = 49,
    },
    {
        labelId = "TaggingShakeCanMale",
        dict = "anim@scripted@freemode@postertag@graffiti_spray@male@",
        name = "shake_can_male",
        flag = 49,
    },
    {
        labelId = "Umbrella",
        dict = "amb@world_human_drinking@coffee@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Umbrella3",
        dict = "luxurymods@animation_female_12",
        name = "animation_female_12_clip",
        flag = 49,
    },
    {
        labelId = "Umbrella4",
        dict = "raini@sharror",
        name = "raini_clip",
        flag = 49,
    },
    {
        labelId = "Vape",
        dict = "amb@world_human_smoking@male@male_b@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Vlog",
        dict = "amb@world_human_mobile_film_shocking@male@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "WalkieTalkie2",
        dict = "ultra@walkie_talkie",
        name = "walkie_talkie",
        flag = 49,
    },
    {
        labelId = "WalkingStick2",
        dict = "missbigscore2aleadinout@bs_2a_2b_int",
        name = "lester_base_idle",
        flag = 49,
    },
    {
        labelId = "WatchStripper2",
        dict = "amb@world_human_strip_watch_stand@male_c@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Weights",
        dict = "amb@world_human_muscle_free_weights@male@barbell@base",
        name = "base",
        flag = 49,
    },
    {
        labelId = "Weights2",
        dict = "amb@world_human_muscle_free_weights@male@barbell@idle_a",
        name = "idle_d",
        flag = 49,
    },
    {
        labelId = "Weights3",
        dict = "amb@prop_human_seat_muscle_bench_press@idle_a",
        name = "idle_a",
        flag = 1,
    },
    {
        labelId = "WhiskeyBottle",
        dict = "amb@world_human_drinking@beer@male@idle_a",
        name = "idle_a",
        flag = 49,
    },
    {
        labelId = "Wine2Bottle",
        dict = "amb@world_human_drinking@beer@female@idle_a",
        name = "idle_e",
        flag = 49,
    },
}


Config.Props = {
    { labelId = "AccGuitar01", model = "prop_acc_guitar_01" }, -- github verified: True
    { labelId = "AmbCiggy01", model = "prop_amb_ciggy_01" }, -- github verified: False
    { labelId = "AmbDonut", model = "prop_amb_donut" }, -- github verified: False
    { labelId = "AmbHandbag01", model = "prop_amb_handbag_01" }, -- github verified: False
    { labelId = "AnimCashPile01", model = "prop_anim_cash_pile_01" }, -- github verified: False
    { labelId = "BaBattleChamopen", model = "ba_prop_battle_champ_open" }, -- github verified: False
    { labelId = "BaBattleVape01", model = "ba_prop_battle_vape_01" }, -- github verified: False
    { labelId = "BaBattleWhiskeyBottle2S", model = "ba_prop_battle_whiskey_bottle_2_s" }, -- github verified: False
    { labelId = "BaClubWaterBottle", model = "ba_prop_club_water_bottle" }, -- github verified: False
    { labelId = "Barbell01", model = "prop_barbell_01" }, -- github verified: True
    { labelId = "Barbell100Kg", model = "prop_barbell_100kg" }, -- github verified: True
    { labelId = "Barbell10Kg", model = "prop_barbell_10kg" }, -- github verified: True
    { labelId = "Barbell20Kg", model = "prop_barbell_20kg" }, -- github verified: True
    { labelId = "Barbell30Kg", model = "prop_barbell_30kg" }, -- github verified: True
    { labelId = "Barbell40Kg", model = "prop_barbell_40kg" }, -- github verified: True
    { labelId = "Barbell50Kg", model = "prop_barbell_50kg" }, -- github verified: True
    { labelId = "Barbell60Kg", model = "prop_barbell_60kg" }, -- github verified: True
    { labelId = "Barbell80Kg", model = "prop_barbell_80kg" }, -- github verified: True
    { labelId = "BeachRing01", model = "prop_beach_ring_01" }, -- github verified: True
    { labelId = "Beachbag01", model = "prop_beachbag_01" }, -- github verified: True
    { labelId = "Beachbag05", model = "prop_beachbag_05" }, -- github verified: True
    { labelId = "Beachbag06", model = "prop_beachbag_06" }, -- github verified: True
    { labelId = "Beer", model = "prop_amb_beer_bottle" }, -- github verified: False
    { labelId = "BeerAm", model = "prop_beer_am" }, -- github verified: True
    { labelId = "BeerAmopen", model = "prop_beer_amopen" }, -- github verified: True
    { labelId = "BeerBox01", model = "prop_beer_box_01" }, -- github verified: True
    { labelId = "BeerLogopen", model = "prop_beer_logopen" }, -- github verified: True
    { labelId = "BeerPissh", model = "prop_beer_pissh" }, -- github verified: True
    { labelId = "Beerdusche", model = "prop_beerdusche" }, -- github verified: True
    { labelId = "BeggersSign01", model = "prop_beggers_sign_01" }, -- github verified: True
    { labelId = "BeggersSign02", model = "prop_beggers_sign_02" }, -- github verified: True
    { labelId = "BeggersSign03", model = "prop_beggers_sign_03" }, -- github verified: True
    { labelId = "BeggersSign04", model = "prop_beggers_sign_04" }, -- github verified: True
    { labelId = "BigBag01", model = "prop_big_bag_01" }, -- github verified: True
    { labelId = "Bin07D", model = "prop_bin_07d" }, -- github verified: True
    { labelId = "Bin08A", model = "prop_bin_08a" }, -- github verified: True
    { labelId = "Bin08Open", model = "prop_bin_08open" }, -- github verified: True
    { labelId = "Binoc01", model = "prop_binoc_01" }, -- github verified: True
    { labelId = "BkrBikerCaseShut", model = "bkr_prop_biker_case_shut" }, -- github verified: True
    { labelId = "BkrDuffelBag01A", model = "bkr_prop_duffel_bag_01a" }, -- github verified: True
    { labelId = "BkrFakeidOpenpassport", model = "bkr_prop_fakeid_openpassport" }, -- github verified: True
    { labelId = "BkrFakeidSingledriverl", model = "bkr_prop_fakeid_singledriverl" }, -- github verified: True
    { labelId = "BkrWeed01Small01B", model = "bkr_prop_weed_01_small_01b" }, -- github verified: True
    { labelId = "BkrWeed01Small01C", model = "bkr_prop_weed_01_small_01c" }, -- github verified: True
    { labelId = "BkrWeedBigbag01A", model = "bkr_prop_weed_bigbag_01a" }, -- github verified: True
    { labelId = "BkrWeedBucketOpen01A", model = "bkr_prop_weed_bucket_open_01a" }, -- github verified: True
    { labelId = "BkrWeedLrg01B", model = "bkr_prop_weed_lrg_01b" }, -- github verified: True
    { labelId = "BloodsplatS", model = "p_bloodsplat_s" }, -- github verified: False
    { labelId = "Bonesaw", model = "prop_bonesaw" }, -- github verified: True
    { labelId = "Bong01", model = "prop_bong_01" }, -- github verified: True
    { labelId = "Bongos01", model = "prop_bongos_01" }, -- github verified: True
    { labelId = "Boombox01", model = "prop_boombox_01" }, -- github verified: True
    { labelId = "Bottle", model = "prop_ld_flow_bottle" }, -- github verified: False
    { labelId = "BottleBrandy", model = "prop_bottle_brandy" }, -- github verified: True
    { labelId = "Brolly01", model = "p_amb_brolly_01" }, -- github verified: False
    { labelId = "Bskball01", model = "prop_bskball_01" }, -- github verified: True
    { labelId = "Burger", model = "prop_cs_burger_01" }, -- github verified: False
    { labelId = "BzzzAnimalFish002", model = "bzzz_animal_fish002" }, -- github verified: False
    { labelId = "BzzzCigarpackCig001", model = "bzzz_cigarpack_cig001" }, -- github verified: False
    { labelId = "BzzzCigarpackCig002", model = "bzzz_cigarpack_cig002" }, -- github verified: False
    { labelId = "BzzzCigarpackCig003", model = "bzzz_cigarpack_cig003" }, -- github verified: False
    { labelId = "BzzzFoodDessertA", model = "bzzz_food_dessert_a" }, -- github verified: False
    { labelId = "BzzzFoodXmasGingerbreadA", model = "bzzz_food_xmas_gingerbread_a" }, -- github verified: False
    { labelId = "BzzzFoodXmasLollipoa", model = "bzzz_food_xmas_lollipop_a" }, -- github verified: False
    { labelId = "BzzzFoodXmasLollipob", model = "bzzz_food_xmas_lollipop_b" }, -- github verified: False
    { labelId = "BzzzFoodXmasLollipoc", model = "bzzz_food_xmas_lollipop_c" }, -- github verified: False
    { labelId = "BzzzFoodXmasLollipod", model = "bzzz_food_xmas_lollipop_d" }, -- github verified: False
    { labelId = "BzzzFoodXmasLollipoe", model = "bzzz_food_xmas_lollipop_e" }, -- github verified: False
    { labelId = "BzzzFoodXmasMacaroonA", model = "bzzz_food_xmas_macaroon_a" }, -- github verified: False
    { labelId = "BzzzFoodXmasMugA", model = "bzzz_food_xmas_mug_a" }, -- github verified: False
    { labelId = "BzzzFoodXmasMugB", model = "bzzz_food_xmas_mug_b" }, -- github verified: False
    { labelId = "BzzzFoodXmasMulledWineA", model = "bzzz_food_xmas_mulled_wine_a" }, -- github verified: False
    { labelId = "BzzzFoodpackCroissant001", model = "bzzz_foodpack_croissant001" }, -- github verified: False
    { labelId = "BzzzFoodpackDonut001", model = "bzzz_foodpack_donut001" }, -- github verified: False
    { labelId = "BzzzFoodpackDonut002", model = "bzzz_foodpack_donut002" }, -- github verified: False
    { labelId = "BzzzGiftBonbonier", model = "bzzz_prop_gift_bonbonier" }, -- github verified: False
    { labelId = "BzzzGiftJewel", model = "bzzz_prop_gift_jewel" }, -- github verified: False
    { labelId = "BzzzGiftOrange", model = "bzzz_prop_gift_orange" }, -- github verified: False
    { labelId = "BzzzGiftPurple", model = "bzzz_prop_gift_purple" }, -- github verified: False
    { labelId = "BzzzIcecreamCherry", model = "bzzz_icecream_cherry" }, -- github verified: False
    { labelId = "BzzzIcecreamChocolate", model = "bzzz_icecream_chocolate" }, -- github verified: False
    { labelId = "BzzzIcecreamLemon", model = "bzzz_icecream_lemon" }, -- github verified: False
    { labelId = "BzzzIcecreamPistachio", model = "bzzz_icecream_pistachio" }, -- github verified: False
    { labelId = "BzzzIcecreamRaspberry", model = "bzzz_icecream_raspberry" }, -- github verified: False
    { labelId = "BzzzIcecreamStracciatella", model = "bzzz_icecream_stracciatella" }, -- github verified: False
    { labelId = "BzzzIcecreamStrawberry", model = "bzzz_icecream_strawberry" }, -- github verified: False
    { labelId = "BzzzIcecreamWalnut", model = "bzzz_icecream_walnut" }, -- github verified: False
    { labelId = "BzzzMurderAxe001", model = "bzzz_murder_axe001" }, -- github verified: False
    { labelId = "BzzzMurderMachete001", model = "bzzz_murder_machete001" }, -- github verified: False
    { labelId = "BzzzPizzahutBoxA", model = "bzzz_pizzahut_box_a" }, -- github verified: False
    { labelId = "BzzzPizzahutCua", model = "bzzz_pizzahut_cup_a" }, -- github verified: False
    { labelId = "BzzzPizzahutMenuA", model = "bzzz_pizzahut_menu_a" }, -- github verified: False
    { labelId = "BzzzTorchFire001", model = "bzzz_prop_torch_fire001" }, -- github verified: False
    { labelId = "CandyPqs", model = "prop_candy_pqs" }, -- github verified: True
    { labelId = "CashCase01", model = "prop_cash_case_01" }, -- github verified: True
    { labelId = "CashCase02", model = "prop_cash_case_02" }, -- github verified: True
    { labelId = "ChArcadeGunBird01A", model = "ch_prop_arcade_gun_bird_01a" }, -- github verified: False
    { labelId = "ChChSecurityCase01A", model = "ch_prop_ch_security_case_01a" }, -- github verified: False
    { labelId = "Chamcool", model = "prop_champ_cool" }, -- github verified: True
    { labelId = "Chamflute", model = "prop_champ_flute" }, -- github verified: True
    { labelId = "ChocEgo", model = "prop_choc_ego" }, -- github verified: True
    { labelId = "Cigar01", model = "prop_cigar_01" }, -- github verified: True
    { labelId = "Cigar02", model = "prop_cigar_02" }, -- github verified: True
    { labelId = "Cigarette", model = "prop_cs_ciggy_01" }, -- github verified: False
    { labelId = "CliffPaper", model = "prop_cliff_paper" }, -- github verified: True
    { labelId = "Clipboard", model = "p_amb_clipboard_01" }, -- github verified: False
    { labelId = "CoffeeCup", model = "p_amb_coffeecup_01" }, -- github verified: False
    { labelId = "Controller01", model = "prop_controller_01" }, -- github verified: True
    { labelId = "CranialSaw", model = "prop_cranial_saw" }, -- github verified: True
    { labelId = "CsBeerBot02", model = "prop_cs_beer_bot_02" }, -- github verified: False
    { labelId = "CsBin01", model = "prop_cs_bin_01" }, -- github verified: False
    { labelId = "CsBin03", model = "prop_cs_bin_03" }, -- github verified: False
    { labelId = "CsBowieKnife", model = "prop_cs_bowie_knife" }, -- github verified: False
    { labelId = "CsBowl01", model = "prop_cs_bowl_01" }, -- github verified: False
    { labelId = "CsDildo01", model = "prop_cs_dildo_01" }, -- github verified: False
    { labelId = "CsHandRadio", model = "prop_cs_hand_radio" }, -- github verified: False
    { labelId = "CsHotdog01", model = "prop_cs_hotdog_01" }, -- github verified: False
    { labelId = "CsHotdog02", model = "prop_cs_hotdog_02" }, -- github verified: False
    { labelId = "CsJoint02", model = "p_cs_joint_02" }, -- github verified: False
    { labelId = "CsMagazine", model = "prop_cs_magazine" }, -- github verified: False
    { labelId = "CsMos", model = "prop_cs_mop_s" }, -- github verified: False
    { labelId = "CsPoliceTorch02", model = "prop_cs_police_torch_02" }, -- github verified: False
    { labelId = "CsProtestSign01", model = "prop_cs_protest_sign_01" }, -- github verified: False
    { labelId = "CsProtestSign03", model = "prop_cs_protest_sign_03" }, -- github verified: False
    { labelId = "CsProtestSign04A", model = "prop_cs_protest_sign_04a" }, -- github verified: False
    { labelId = "CsProtestSign04B", model = "prop_cs_protest_sign_04b" }, -- github verified: False
    { labelId = "CsShoppingBag", model = "prop_cs_shopping_bag" }, -- github verified: False
    { labelId = "CsSolGlasses", model = "prop_cs_sol_glasses" }, -- github verified: False
    { labelId = "CsSprayCan", model = "prop_cs_spray_can" }, -- github verified: False
    { labelId = "CsStreetBinbag01", model = "prop_cs_street_binbag_01" }, -- github verified: False
    { labelId = "CsTablet", model = "prop_cs_tablet" }, -- github verified: False
    { labelId = "CsWalkingStick", model = "prop_cs_walking_stick" }, -- github verified: False
    { labelId = "CsWhiskeyBottle", model = "prop_cs_whiskey_bottle" }, -- github verified: False
    { labelId = "CurlBar01", model = "prop_curl_bar_01" }, -- github verified: True
    { labelId = "Donut02", model = "prop_donut_02" }, -- github verified: True
    { labelId = "DrinkChamp", model = "prop_drink_champ" }, -- github verified: True
    { labelId = "DrinkRedwine", model = "prop_drink_redwine" }, -- github verified: True
    { labelId = "DrinkWhisky", model = "prop_drink_whisky" }, -- github verified: True
    { labelId = "EcolaCan", model = "prop_ecola_can" }, -- github verified: True
    { labelId = "ElGuitar01", model = "prop_el_guitar_01" }, -- github verified: True
    { labelId = "ElGuitar02", model = "prop_el_guitar_02" }, -- github verified: True
    { labelId = "ElGuitar03", model = "prop_el_guitar_03" }, -- github verified: True
    { labelId = "EntAnimDogPoo", model = "ent_anim_dog_poo" }, -- github verified: False
    { labelId = "EntAnimLeafBlower", model = "ent_anim_leaf_blower" }, -- github verified: False
    { labelId = "ExgrdBzgasSmoke", model = "exp_grd_bzgas_smoke" }, -- github verified: False
    { labelId = "FibBadge", model = "prop_fib_badge" }, -- github verified: True
    { labelId = "FishSlice01", model = "prop_fish_slice_01" }, -- github verified: True
    { labelId = "FishingRod01", model = "prop_fishing_rod_01" }, -- github verified: True
    { labelId = "FoodBag1", model = "prop_food_bag1" }, -- github verified: True
    { labelId = "FoodBsBag01", model = "prop_food_bs_bag_01" }, -- github verified: True
    { labelId = "FoodBsBurger2", model = "prop_food_bs_burger2" }, -- github verified: True
    { labelId = "FoodBsChips", model = "prop_food_bs_chips" }, -- github verified: True
    { labelId = "FoodBsCoffee", model = "prop_food_bs_coffee" }, -- github verified: True
    { labelId = "FoodBsJuice01", model = "prop_food_bs_juice01" }, -- github verified: True
    { labelId = "FoodBsTray02", model = "prop_food_bs_tray_02" }, -- github verified: True
    { labelId = "FoodBsTray03", model = "prop_food_bs_tray_03" }, -- github verified: True
    { labelId = "FoodCbBag01", model = "prop_food_cb_bag_01" }, -- github verified: True
    { labelId = "FoodCbTray02", model = "prop_food_cb_tray_02" }, -- github verified: True
    { labelId = "FoodTray02", model = "prop_food_tray_02" }, -- github verified: True
    { labelId = "FoodTray03", model = "prop_food_tray_03" }, -- github verified: True
    { labelId = "FranklinDl", model = "prop_franklin_dl" }, -- github verified: False
    { labelId = "Ghettoblast02", model = "prop_ghettoblast_02" }, -- github verified: True
    { labelId = "GolfWood01", model = "prop_golf_wood_01" }, -- github verified: True
    { labelId = "GunCase01", model = "prop_gun_case_01" }, -- github verified: True
    { labelId = "H4H4CaviarSpoon01A", model = "h4_prop_h4_caviar_spoon_01a" }, -- github verified: False
    { labelId = "H4H4CaviarTin01A", model = "h4_prop_h4_caviar_tin_01a" }, -- github verified: False
    { labelId = "H4H4Chamtray01B", model = "h4_prop_h4_champ_tray_01b" }, -- github verified: False
    { labelId = "H4H4Chamtray01C", model = "h4_prop_h4_champ_tray_01c" }, -- github verified: False
    { labelId = "HeiHeistBox", model = "hei_prop_heist_box" }, -- github verified: False
    { labelId = "ImtoolBox01A", model = "imp_prop_tool_box_01a" }, -- github verified: False
    { labelId = "IndFirework01", model = "ind_prop_firework_01" }, -- github verified: True
    { labelId = "IngCamera01", model = "prop_ing_camera_01" }, -- github verified: True
    { labelId = "IngMicrophonel01", model = "p_ing_microphonel_01" }, -- github verified: True
    { labelId = "LdCase01", model = "prop_ld_case_01" }, -- github verified: False
    { labelId = "LdHandbag", model = "prop_ld_handbag" }, -- github verified: False
    { labelId = "LdIdCard002", model = "p_ld_id_card_002" }, -- github verified: False
    { labelId = "LdShovelDirt", model = "prop_ld_shovel_dirt" }, -- github verified: False
    { labelId = "LdSuitcase01", model = "prop_ld_suitcase_01" }, -- github verified: False
    { labelId = "LeafBlower01", model = "prop_leaf_blower_01" }, -- github verified: True
    { labelId = "LspdBadge", model = "prop_lspd_badge" }, -- github verified: False
    { labelId = "Mcone02", model = "prop_mp_cone_02" }, -- github verified: False
    { labelId = "Megaphone01", model = "prop_megaphone_01" }, -- github verified: True
    { labelId = "MichaelBackpack", model = "prop_michael_backpack" }, -- github verified: False
    { labelId = "MichaelBackpackS", model = "p_michael_backpack_s" }, -- github verified: False
    { labelId = "MichaelSecId", model = "prop_michael_sec_id" }, -- github verified: False
    { labelId = "MrRaspberry01", model = "prop_mr_raspberry_01" }, -- github verified: False
    { labelId = "NattyLollipop01", model = "natty_lollipop01" }, -- github verified: False
    { labelId = "NattyLollipospin01", model = "natty_lollipop_spin01" }, -- github verified: False
    { labelId = "NattyLollipospin02", model = "natty_lollipop_spin02" }, -- github verified: False
    { labelId = "NattyLollipospin03", model = "natty_lollipop_spin03" }, -- github verified: False
    { labelId = "NattyLollipospin04", model = "natty_lollipop_spin04" }, -- github verified: False
    { labelId = "NattyLollipospin05", model = "natty_lollipop_spin05" }, -- github verified: False
    { labelId = "NattyLollipospiral01", model = "natty_lollipop_spiral01" }, -- github verified: False
    { labelId = "NattyLollipospiral02", model = "natty_lollipop_spiral02" }, -- github verified: False
    { labelId = "NattyLollipospiral03", model = "natty_lollipop_spiral03" }, -- github verified: False
    { labelId = "NattyLollipospiral04", model = "natty_lollipop_spiral04" }, -- github verified: False
    { labelId = "NattyLollipospiral05", model = "natty_lollipop_spiral05" }, -- github verified: False
    { labelId = "NattyLollipospiral06", model = "natty_lollipop_spiral06" }, -- github verified: False
    { labelId = "NgProcCigpak01A", model = "ng_proc_cigpak01a" }, -- github verified: False
    { labelId = "NgProcPaperNewsQuik", model = "ng_proc_paper_news_quik" }, -- github verified: False
    { labelId = "NgProcPaperNewsRag", model = "ng_proc_paper_news_rag" }, -- github verified: False
    { labelId = "Notepad01", model = "prop_notepad_01" }, -- github verified: True
    { labelId = "Novel01", model = "prop_novel_01" }, -- github verified: True
    { labelId = "Pacamera01", model = "prop_pap_camera_01" }, -- github verified: True
    { labelId = "ParkingWand01", model = "prop_parking_wand_01" }, -- github verified: True
    { labelId = "Pencil01", model = "prop_pencil_01" }, -- github verified: True
    { labelId = "Phone", model = "prop_npc_phone_02" }, -- github verified: False
    { labelId = "PhoneIng", model = "prop_phone_ing" }, -- github verified: True
    { labelId = "Pineapple", model = "prop_pineapple" }, -- github verified: True
    { labelId = "PizzaBox02", model = "prop_pizza_box_02" }, -- github verified: True
    { labelId = "PlasticCu02", model = "prop_plastic_cup_02" }, -- github verified: True
    { labelId = "PoliceIdBoard", model = "prop_police_id_board" }, -- github verified: True
    { labelId = "PornMag02", model = "prop_porn_mag_02" }, -- github verified: True
    { labelId = "PornMag03", model = "prop_porn_mag_03" }, -- github verified: True
    { labelId = "PpricefishingAugur", model = "pprp_icefishing_augur" }, -- github verified: False
    { labelId = "PpricefishingBox01", model = "pprp_icefishing_box_01" }, -- github verified: False
    { labelId = "PpricefishingBox02", model = "pprp_icefishing_box_02" }, -- github verified: False
    { labelId = "PrideSign01", model = "pride_sign_01" }, -- github verified: False
    { labelId = "Prideflag1", model = "prideflag1" }, -- github verified: False
    { labelId = "Prideflag2", model = "prideflag2" }, -- github verified: False
    { labelId = "Prideflag3", model = "prideflag3" }, -- github verified: False
    { labelId = "Prideflag4", model = "prideflag4" }, -- github verified: False
    { labelId = "Prideflag5", model = "prideflag5" }, -- github verified: False
    { labelId = "Prideflag6", model = "prideflag6" }, -- github verified: False
    { labelId = "Prideflag7", model = "prideflag7" }, -- github verified: False
    { labelId = "Prideflag8", model = "prideflag8" }, -- github verified: False
    { labelId = "Prideflag9", model = "prideflag9" }, -- github verified: False
    { labelId = "RehRehLanternPk01A", model = "reh_prop_reh_lantern_pk_01a" }, -- github verified: False
    { labelId = "RehRehLanternPk01B", model = "reh_prop_reh_lantern_pk_01b" }, -- github verified: False
    { labelId = "RehRehLanternPk01C", model = "reh_prop_reh_lantern_pk_01c" }, -- github verified: False
    { labelId = "Roadcone02B", model = "prop_roadcone02b" }, -- github verified: True
    { labelId = "RumBottle", model = "prop_rum_bottle" }, -- github verified: True
    { labelId = "Sandwich01", model = "prop_sandwich_01" }, -- github verified: True
    { labelId = "Scalpel", model = "prop_scalpel" }, -- github verified: True
    { labelId = "ScrBaClubChampagneSpray", model = "scr_ba_club_champagne_spray" }, -- github verified: False
    { labelId = "ScrBikeCfidCameraFlash", model = "scr_bike_cfid_camera_flash" }, -- github verified: False
    { labelId = "ScrIndefireworkTrailSpawn", model = "scr_indep_firework_trail_spawn" }, -- github verified: False
    { labelId = "ScrMich4FireworkTrailburst", model = "scr_mich4_firework_trailburst" }, -- github verified: False
    { labelId = "ScrTnMeetPhoneCameraFlash", model = "scr_tn_meet_phone_camera_flash" }, -- github verified: False
    { labelId = "ScrTrevPuke", model = "scr_trev_puke" }, -- github verified: False
    { labelId = "ScrXsMoneyRain", model = "scr_xs_money_rain" }, -- github verified: False
    { labelId = "ScullyBlm", model = "scully_blm" }, -- github verified: False
    { labelId = "ScullyBoba", model = "scully_boba" }, -- github verified: False
    { labelId = "ScullyBoba2", model = "scully_boba2" }, -- github verified: False
    { labelId = "ScullyBoba3", model = "scully_boba3" }, -- github verified: False
    { labelId = "ScullyPho", model = "scully_pho" }, -- github verified: False
    { labelId = "ScullySpoonPho", model = "scully_spoon_pho" }, -- github verified: False
    { labelId = "SecurityCase01", model = "prop_security_case_01" }, -- github verified: True
    { labelId = "SfSfApple01B", model = "sf_prop_sf_apple_01b" }, -- github verified: False
    { labelId = "SfSfElGuitar02A", model = "sf_prop_sf_el_guitar_02a" }, -- github verified: False
    { labelId = "SfSfGuitarCase01A", model = "sf_prop_sf_guitar_case_01a" }, -- github verified: False
    { labelId = "ShoppingBags02", model = "prop_shopping_bags02" }, -- github verified: True
    { labelId = "SignFreewayentrance", model = "prop_sign_freewayentrance" }, -- github verified: True
    { labelId = "SignRoad01A", model = "prop_sign_road_01a" }, -- github verified: True
    { labelId = "SignRoad02A", model = "prop_sign_road_02a" }, -- github verified: True
    { labelId = "SignRoad03D", model = "prop_sign_road_03d" }, -- github verified: True
    { labelId = "SignRoad04A", model = "prop_sign_road_04a" }, -- github verified: True
    { labelId = "SignRoad04W", model = "prop_sign_road_04w" }, -- github verified: True
    { labelId = "SignRoad05A", model = "prop_sign_road_05a" }, -- github verified: True
    { labelId = "SignRoad05T", model = "prop_sign_road_05t" }, -- github verified: True
    { labelId = "SignRoad06C", model = "prop_sign_road_06c" }, -- github verified: True
    { labelId = "SignRoad06E", model = "prop_sign_road_06e" }, -- github verified: True
    { labelId = "SignRoad06G", model = "prop_sign_road_06g" }, -- github verified: True
    { labelId = "SingleRose", model = "prop_single_rose" }, -- github verified: True
    { labelId = "SkidChair02", model = "prop_skid_chair_02" }, -- github verified: True
    { labelId = "SnowFlower02", model = "prop_snow_flower_02" }, -- github verified: False
    { labelId = "SnowSignRoad01A", model = "prop_snow_sign_road_01a" }, -- github verified: False
    { labelId = "Sponge01", model = "prop_sponge_01" }, -- github verified: True
    { labelId = "Stickbfly", model = "prop_stickbfly" }, -- github verified: True
    { labelId = "Stickhbird", model = "prop_stickhbird" }, -- github verified: True
    { labelId = "Suitcase01C", model = "prop_suitcase_01c" }, -- github verified: True
    { labelId = "SurfBoard01", model = "prop_surf_board_01" }, -- github verified: True
    { labelId = "Syringe01", model = "prop_syringe_01" }, -- github verified: True
    { labelId = "Taco01", model = "prop_taco_01" }, -- github verified: True
    { labelId = "TennisBag01", model = "prop_tennis_bag_01" }, -- github verified: True
    { labelId = "TennisRack01", model = "prop_tennis_rack_01" }, -- github verified: True
    { labelId = "TequilaBottle", model = "prop_tequila_bottle" }, -- github verified: True
    { labelId = "ToiletRoll01", model = "prop_toilet_roll_01" }, -- github verified: True
    { labelId = "ToolBox04", model = "prop_tool_box_04" }, -- github verified: True
    { labelId = "ToolBroom", model = "prop_tool_broom" }, -- github verified: True
    { labelId = "ToolConsaw", model = "prop_tool_consaw" }, -- github verified: True
    { labelId = "ToolDrill", model = "prop_tool_drill" }, -- github verified: True
    { labelId = "ToolFireaxe", model = "prop_tool_fireaxe" }, -- github verified: True
    { labelId = "ToolHammer", model = "prop_tool_hammer" }, -- github verified: True
    { labelId = "ToolJackham", model = "prop_tool_jackham" }, -- github verified: True
    { labelId = "ToolMallet", model = "prop_tool_mallet" }, -- github verified: True
    { labelId = "ToolNailgun", model = "prop_tool_nailgun" }, -- github verified: True
    { labelId = "ToolPickaxe", model = "prop_tool_pickaxe" }, -- github verified: True
    { labelId = "ToolRake", model = "prop_tool_rake" }, -- github verified: True
    { labelId = "ToolShovel", model = "prop_tool_shovel" }, -- github verified: True
    { labelId = "ToolShovel5", model = "prop_tool_shovel5" }, -- github verified: True
    { labelId = "TouristMa01", model = "prop_tourist_map_01" }, -- github verified: True
    { labelId = "UltraRingcase", model = "ultra_ringcase" }, -- github verified: False
    { labelId = "VBmike01", model = "prop_v_bmike_01" }, -- github verified: False
    { labelId = "VCam01", model = "prop_v_cam_01" }, -- github verified: False
    { labelId = "VIlevMrRasberryclean", model = "v_ilev_mr_rasberryclean" }, -- github verified: False
    { labelId = "VResTreRemote", model = "v_res_tre_remote" }, -- github verified: True
    { labelId = "VResTtCan03", model = "v_res_tt_can03" }, -- github verified: True
    { labelId = "VResTtMilk", model = "v_res_tt_milk" }, -- github verified: True
    { labelId = "VResTtPizzaplate", model = "v_res_tt_pizzaplate" }, -- github verified: True
    { labelId = "VResTtPornmag01", model = "v_res_tt_pornmag01" }, -- github verified: True
    { labelId = "VResTtPornmag02", model = "v_res_tt_pornmag02" }, -- github verified: True
    { labelId = "VResTtPornmag03", model = "v_res_tt_pornmag03" }, -- github verified: True
    { labelId = "VResTtPornmag04", model = "v_res_tt_pornmag04" }, -- github verified: True
    { labelId = "VRetGcBag02", model = "v_ret_gc_bag02" }, -- github verified: True
    { labelId = "VRetGcCashreg", model = "v_ret_gc_cashreg" }, -- github verified: True
    { labelId = "VRetMlBeeram", model = "v_ret_ml_beeram" }, -- github verified: True
    { labelId = "VRetMlBeerbar", model = "v_ret_ml_beerbar" }, -- github verified: True
    { labelId = "VRetMlBeerben1", model = "v_ret_ml_beerben1" }, -- github verified: True
    { labelId = "VRetMlBeerbla1", model = "v_ret_ml_beerbla1" }, -- github verified: True
    { labelId = "VRetMlBeerdus", model = "v_ret_ml_beerdus" }, -- github verified: True
    { labelId = "VRetMlBeerjak1", model = "v_ret_ml_beerjak1" }, -- github verified: True
    { labelId = "VRetMlBeerlog1", model = "v_ret_ml_beerlog1" }, -- github verified: True
    { labelId = "VRetMlBeerpis1", model = "v_ret_ml_beerpis1" }, -- github verified: True
    { labelId = "VRetMlBeerpride", model = "v_ret_ml_beerpride" }, -- github verified: True
    { labelId = "VRetMlChips2", model = "v_ret_ml_chips2" }, -- github verified: True
    { labelId = "VRetPsBag01", model = "v_ret_ps_bag_01" }, -- github verified: True
    { labelId = "VRetPsBag02", model = "v_ret_ps_bag_02" }, -- github verified: True
    { labelId = "VRetTaFirstaid", model = "v_ret_ta_firstaid" }, -- github verified: True
    { labelId = "VegCro03Pump", model = "prop_veg_crop_03_pump" }, -- github verified: False
    { labelId = "VodkaBottle", model = "prop_vodka_bottle" }, -- github verified: True
    { labelId = "VwCasinoArtGuitar01A", model = "vw_prop_casino_art_guitar_01a" }, -- github verified: False
    { labelId = "VwCasinoShoppingBag01A", model = "vw_prop_casino_shopping_bag_01a" }, -- github verified: False
    { labelId = "VwVwTray01A", model = "vw_prop_vw_tray_01a" }, -- github verified: False
    { labelId = "WAmDigiscanner", model = "w_am_digiscanner" }, -- github verified: False
    { labelId = "WAmJerrycan", model = "w_am_jerrycan" }, -- github verified: False
    { labelId = "WPiHeavypistol", model = "w_pi_heavypistol" }, -- github verified: False
    { labelId = "WeedBlock01", model = "prop_weed_block_01" }, -- github verified: True
    { labelId = "WheatGrassGlass", model = "prop_wheat_grass_glass" }, -- github verified: True
    { labelId = "WheatGrassHalf", model = "prop_wheat_grass_half" }, -- github verified: True
    { labelId = "WheelTyre", model = "prop_wheel_tyre" }, -- github verified: False
    { labelId = "WineRose", model = "prop_wine_rose" }, -- github verified: True
    { labelId = "WineWhite", model = "prop_wine_white" }, -- github verified: True
    { labelId = "XmX17BagMed01A", model = "xm_prop_x17_bag_med_01a" }, -- github verified: False
    { labelId = "Xm3Xm3Bong01A", model = "xm3_prop_xm3_bong_01a" }, -- github verified: False
    { labelId = "Xm3Xm3Papers01A", model = "xm3_prop_xm3_papers_01a" }, -- github verified: False
    { labelId = "Xm3Xm3Present01A", model = "xm3_prop_xm3_present_01a" }, -- github verified: False
    { labelId = "Xm3Xm3ToolBox01A", model = "xm3_prop_xm3_tool_box_01a" }, -- github verified: False
    { labelId = "Xm3Xm3ToolBox02A", model = "xm3_prop_xm3_tool_box_02a" }, -- github verified: False
    { labelId = "Xm3Xm3ToyDog01A", model = "xm3_prop_xm3_toy_dog_01a" }, -- github verified: False
    { labelId = "XsArenaScreenTv01", model = "xs_prop_arena_screen_tv_01" }, -- github verified: False
}


Config.Bones = {
    { labelId = "boneRightHand", id = 57005 },
    { labelId = "boneLeftHand", id = 18905 },
    { labelId = "boneRightWrist", id = 28422 },
    { labelId = "boneLeftWrist", id = 60309 },
    { labelId = "boneHead", id = 31086 },
    { labelId = "boneMouth", id = 47495 },
    { labelId = "boneSpine", id = 24818 },
    { labelId = "boneRightFoot", id = 52301 },
    { labelId = "boneLeftFoot", id = 14201 },
}
