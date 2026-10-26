// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// The question Time Tracking asks after time away from the Mac while an
/// entry ran.
struct TimeTrackingAwayStrings {
    let awayFormat: String
    let keep: String
    let discard: String
    let discardAndStop: String
}

extension FeatureStrings {
    static func timeTrackingAway(_ language: AppLanguage) -> TimeTrackingAwayStrings {
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

extension TimeTrackingAwayStrings {
    static let enUS = TimeTrackingAwayStrings(
        awayFormat: "You were away for %@", keep: "Keep", discard: "Discard", discardAndStop: "Discard and stop")
    static let ptBR = TimeTrackingAwayStrings(
        awayFormat: "Tempo ausente: %@", keep: "Manter", discard: "Descartar", discardAndStop: "Descartar e parar")
    static let tr = TimeTrackingAwayStrings(
        awayFormat: "%@ boyunca uzaktaydınız", keep: "Koru", discard: "Kaldır", discardAndStop: "Kaldır ve durdur")
    static let ru = TimeTrackingAwayStrings(
        awayFormat: "Вас не было %@", keep: "Оставить", discard: "Убрать", discardAndStop: "Убрать и остановить")
    static let es = TimeTrackingAwayStrings(
        awayFormat: "Tiempo fuera: %@", keep: "Conservar", discard: "Descartar",
        discardAndStop: "Descartar y detener")
    static let sk = TimeTrackingAwayStrings(
        awayFormat: "Boli ste preč %@", keep: "Ponechať", discard: "Zahodiť", discardAndStop: "Zahodiť a zastaviť")
    static let de = TimeTrackingAwayStrings(
        awayFormat: "Du warst %@ weg", keep: "Behalten", discard: "Verwerfen", discardAndStop: "Verwerfen und stoppen")
    static let fr = TimeTrackingAwayStrings(
        awayFormat: "Absence de %@", keep: "Conserver", discard: "Supprimer", discardAndStop: "Supprimer et arrêter")
    static let it = TimeTrackingAwayStrings(
        awayFormat: "Assenza di %@", keep: "Mantieni", discard: "Scarta", discardAndStop: "Scarta e ferma")
    static let ja = TimeTrackingAwayStrings(
        awayFormat: "%@ 離席していました", keep: "残す", discard: "破棄", discardAndStop: "破棄して停止")
    static let ko = TimeTrackingAwayStrings(
        awayFormat: "%@ 동안 자리를 비웠습니다", keep: "유지", discard: "버리기", discardAndStop: "버리고 중지")
    static let uk = TimeTrackingAwayStrings(
        awayFormat: "Вас не було %@", keep: "Залишити", discard: "Прибрати", discardAndStop: "Прибрати й зупинити")
    static let zhHans = TimeTrackingAwayStrings(
        awayFormat: "你离开了 %@", keep: "保留", discard: "舍弃", discardAndStop: "舍弃并停止")
    static let zhTW = TimeTrackingAwayStrings(
        awayFormat: "你離開了 %@", keep: "保留", discard: "捨棄", discardAndStop: "捨棄並停止")
    static let zhHK = TimeTrackingAwayStrings(
        awayFormat: "你離開了 %@", keep: "保留", discard: "捨棄", discardAndStop: "捨棄並停止")
}
