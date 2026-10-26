// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// What Time Tracking adds outside its panel: the Command Bar rows, the
/// global shortcut and the notice either of them shows.
struct TimeTrackingCommandStrings {
    let startTimer: String
    let stopTimer: String
    let continueFormat: String
    let shortcutTitle: String
    let startedFormat: String
    let stoppedFormat: String
}

extension FeatureStrings {
    static func timeTrackingCommands(_ language: AppLanguage) -> TimeTrackingCommandStrings {
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

extension TimeTrackingCommandStrings {
    static let enUS = TimeTrackingCommandStrings(
        startTimer: "Start timer", stopTimer: "Stop timer", continueFormat: "Continue %@",
        shortcutTitle: "Start or stop timer", startedFormat: "Started %@", stoppedFormat: "Stopped %@")
    static let ptBR = TimeTrackingCommandStrings(
        startTimer: "Iniciar cronômetro", stopTimer: "Parar cronômetro", continueFormat: "Continuar %@",
        shortcutTitle: "Iniciar ou parar cronômetro", startedFormat: "Iniciado: %@", stoppedFormat: "Parado: %@")
    static let tr = TimeTrackingCommandStrings(
        startTimer: "Zamanlayıcıyı başlat", stopTimer: "Zamanlayıcıyı durdur", continueFormat: "%@ ile devam et",
        shortcutTitle: "Zamanlayıcıyı başlat veya durdur", startedFormat: "Başlatıldı: %@",
        stoppedFormat: "Durduruldu: %@")
    static let ru = TimeTrackingCommandStrings(
        startTimer: "Запустить таймер", stopTimer: "Остановить таймер", continueFormat: "Продолжить: %@",
        shortcutTitle: "Запустить или остановить таймер", startedFormat: "Запущено: %@",
        stoppedFormat: "Остановлено: %@")
    static let es = TimeTrackingCommandStrings(
        startTimer: "Iniciar temporizador", stopTimer: "Detener temporizador", continueFormat: "Continuar %@",
        shortcutTitle: "Iniciar o detener temporizador", startedFormat: "Iniciado: %@",
        stoppedFormat: "Detenido: %@")
    static let sk = TimeTrackingCommandStrings(
        startTimer: "Spustiť časovač", stopTimer: "Zastaviť časovač", continueFormat: "Pokračovať: %@",
        shortcutTitle: "Spustiť alebo zastaviť časovač", startedFormat: "Spustené: %@",
        stoppedFormat: "Zastavené: %@")
    static let de = TimeTrackingCommandStrings(
        startTimer: "Timer starten", stopTimer: "Timer stoppen", continueFormat: "%@ fortsetzen",
        shortcutTitle: "Timer starten oder stoppen", startedFormat: "Gestartet: %@", stoppedFormat: "Gestoppt: %@")
    static let fr = TimeTrackingCommandStrings(
        startTimer: "Démarrer le minuteur", stopTimer: "Arrêter le minuteur", continueFormat: "Reprendre %@",
        shortcutTitle: "Démarrer ou arrêter le minuteur", startedFormat: "Démarré\u{00A0}: %@",
        stoppedFormat: "Arrêté\u{00A0}: %@")
    static let it = TimeTrackingCommandStrings(
        startTimer: "Avvia timer", stopTimer: "Ferma timer", continueFormat: "Riprendi %@",
        shortcutTitle: "Avvia o ferma il timer", startedFormat: "Avviato: %@", stoppedFormat: "Fermato: %@")
    static let ja = TimeTrackingCommandStrings(
        startTimer: "タイマーを開始", stopTimer: "タイマーを停止", continueFormat: "%@を続ける",
        shortcutTitle: "タイマーを開始または停止", startedFormat: "開始：%@", stoppedFormat: "停止：%@")
    static let ko = TimeTrackingCommandStrings(
        startTimer: "타이머 시작", stopTimer: "타이머 중지", continueFormat: "%@ 계속",
        shortcutTitle: "타이머 시작 또는 중지", startedFormat: "시작됨: %@", stoppedFormat: "중지됨: %@")
    static let uk = TimeTrackingCommandStrings(
        startTimer: "Запустити таймер", stopTimer: "Зупинити таймер", continueFormat: "Продовжити: %@",
        shortcutTitle: "Запустити або зупинити таймер", startedFormat: "Запущено: %@",
        stoppedFormat: "Зупинено: %@")
    static let zhHans = TimeTrackingCommandStrings(
        startTimer: "开始计时", stopTimer: "停止计时", continueFormat: "继续“%@”",
        shortcutTitle: "开始或停止计时", startedFormat: "已开始：%@", stoppedFormat: "已停止：%@")
    static let zhTW = TimeTrackingCommandStrings(
        startTimer: "開始計時", stopTimer: "停止計時", continueFormat: "繼續「%@」",
        shortcutTitle: "開始或停止計時", startedFormat: "已開始：%@", stoppedFormat: "已停止：%@")
    static let zhHK = TimeTrackingCommandStrings(
        startTimer: "開始計時", stopTimer: "停止計時", continueFormat: "繼續「%@」",
        shortcutTitle: "開始或停止計時", startedFormat: "已開始：%@", stoppedFormat: "已停止：%@")
}
