// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// What Time Tracking adds to Dynamic Island: the closed island's activity
/// and the link with the island timer's Pomodoro.
struct TimeTrackingIslandStrings {
    let activity: String
    let activityHint: String
    let followsPomodoro: String
    let followsPomodoroHint: String
}

extension FeatureStrings {
    static func timeTrackingIsland(_ language: AppLanguage) -> TimeTrackingIslandStrings {
        switch language {
        case .enUS: return .enUS
        case .ptBR: return .ptBR
        case .tr: return .tr
        case .ru: return .ru
        case .es: return .es
        case .sk: return .sk
        case .de: return .de
        case .fr: return .fr
        case .it: return .it
        case .ja: return .ja
        case .ko: return .ko
        case .uk: return .uk
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        }
    }
}

extension TimeTrackingIslandStrings {
    static let enUS = TimeTrackingIslandStrings(
        activity: "Show the running entry in the closed island",
        activityHint: "Its icon appears beside the camera, with the time it has run so far.",
        followsPomodoro: "Track Pomodoro focus phases",
        followsPomodoroHint: "A focus phase continues your latest entry, or starts one, and a break stops it.")
    static let ptBR = TimeTrackingIslandStrings(
        activity: "Mostrar o registro em andamento na ilha fechada",
        activityHint: "O ícone aparece ao lado da câmera, com o tempo decorrido até agora.",
        followsPomodoro: "Registrar as fases de foco do Pomodoro",
        followsPomodoroHint: "Uma fase de foco continua seu último registro, ou inicia um, e uma pausa o interrompe.")
    static let tr = TimeTrackingIslandStrings(
        activity: "Süren kaydı kapalı adada göster",
        activityHint: "Simgesi, şimdiye kadar geçen süreyle kameranın yanında görünür.",
        followsPomodoro: "Pomodoro odaklanma aşamalarını kaydet",
        followsPomodoroHint: "Bir odaklanma aşaması son kaydınızı sürdürür ya da yeni bir kayıt başlatır, mola ise onu durdurur.")
    static let ru = TimeTrackingIslandStrings(
        activity: "Показывать текущую запись в закрытом острове",
        activityHint: "Её значок появляется рядом с камерой вместе с уже прошедшим временем.",
        followsPomodoro: "Учитывать фазы работы Помодоро",
        followsPomodoroHint: "Фаза работы продолжает последнюю запись или начинает новую, а перерыв её останавливает.")
    static let es = TimeTrackingIslandStrings(
        activity: "Mostrar el registro en curso en la isla cerrada",
        activityHint: "Su icono aparece junto a la cámara, con el tiempo transcurrido hasta ahora.",
        followsPomodoro: "Registrar las fases de concentración del Pomodoro",
        followsPomodoroHint: "Una fase de concentración continúa tu último registro, o empieza uno, y un descanso lo detiene.")
    static let sk = TimeTrackingIslandStrings(
        activity: "Zobraziť prebiehajúci záznam v zatvorenom Dynamic Island",
        activityHint: "Jeho ikona sa zobrazí vedľa kamery spolu s doteraz uplynutým časom.",
        followsPomodoro: "Zaznamenávať fázy sústredenia Pomodoro",
        followsPomodoroHint: "Fáza sústredenia pokračuje vo vašom poslednom zázname alebo začne nový a prestávka ho zastaví.")
    static let de = TimeTrackingIslandStrings(
        activity: "Laufenden Eintrag in der geschlossenen Insel zeigen",
        activityHint: "Sein Symbol erscheint neben der Kamera, mit der bisher erfassten Zeit.",
        followsPomodoro: "Pomodoro-Fokusphasen erfassen",
        followsPomodoroHint: "Eine Fokusphase setzt deinen letzten Eintrag fort oder startet einen, eine Pause stoppt ihn.")
    static let fr = TimeTrackingIslandStrings(
        activity: "Afficher l’entrée en cours dans l’île fermée",
        activityHint: "Son icône apparaît à côté de la caméra, avec le temps écoulé jusqu’ici.",
        followsPomodoro: "Suivre les phases de concentration Pomodoro",
        followsPomodoroHint: "Une phase de concentration reprend votre dernière entrée, ou en démarre une, et une pause l’arrête.")
    static let it = TimeTrackingIslandStrings(
        activity: "Mostra la registrazione in corso nell’isola chiusa",
        activityHint: "La sua icona appare accanto alla fotocamera, con il tempo trascorso finora.",
        followsPomodoro: "Registra le fasi di concentrazione del Pomodoro",
        followsPomodoroHint: "Una fase di concentrazione riprende la tua ultima registrazione, o ne avvia una, e una pausa la ferma.")
    static let ja = TimeTrackingIslandStrings(
        activity: "実行中の記録を閉じた島に表示",
        activityHint: "記録のアイコンがカメラの横に表示され、これまでの経過時間も表示されます。",
        followsPomodoro: "ポモドーロの集中フェーズを記録",
        followsPomodoroHint: "集中フェーズが始まると最新の記録を再開するか新しく開始し、休憩で停止します。")
    static let ko = TimeTrackingIslandStrings(
        activity: "닫힌 섬에 진행 중인 기록 표시",
        activityHint: "기록의 아이콘이 카메라 옆에 지금까지 경과한 시간과 함께 표시됩니다.",
        followsPomodoro: "뽀모도로 집중 단계 기록",
        followsPomodoroHint: "집중 단계가 시작되면 최근 기록을 이어가거나 새로 시작하고, 휴식이 되면 멈춥니다.")
    static let uk = TimeTrackingIslandStrings(
        activity: "Показувати поточний запис у закритому острівці",
        activityHint: "Його значок з’являється біля камери разом із часом, що вже минув.",
        followsPomodoro: "Враховувати фази зосередженості Помодоро",
        followsPomodoroHint: "Фаза зосередженості продовжує останній запис або починає новий, а перерва його зупиняє.")
    static let zhHans = TimeTrackingIslandStrings(
        activity: "在收起的岛中显示进行中的记录",
        activityHint: "记录的图标会显示在摄像头旁，并附上目前已用的时间。",
        followsPomodoro: "记录番茄钟专注阶段",
        followsPomodoroHint: "专注阶段开始时继续最近的记录，没有记录时新建一条；休息时停止。")
    static let zhTW = TimeTrackingIslandStrings(
        activity: "在收合的島中顯示進行中的記錄",
        activityHint: "記錄的圖示會顯示在相機旁，並附上目前已經過的時間。",
        followsPomodoro: "記錄番茄鐘專注階段",
        followsPomodoroHint: "專注階段開始時繼續最近的記錄，沒有記錄時新增一筆；休息時停止。")
    static let zhHK = TimeTrackingIslandStrings(
        activity: "在收合的島中顯示進行中的記錄",
        activityHint: "記錄的圖示會顯示在相機旁，並附上目前已過的時間。",
        followsPomodoro: "記錄番茄鐘專注時段",
        followsPomodoroHint: "專注時段開始時繼續最近的記錄，沒有記錄時新增一項；休息時停止。")
}
