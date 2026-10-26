// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Correcting an entry's times and adding one after the fact.
struct TimeTrackingEditStrings {
    let editTimes: String
    let editStart: String
    let addEntry: String
    let startLabel: String
    let endLabel: String
    let save: String
    let cancel: String
    let endBeforeStart: String
    let inFuture: String
    let overlaps: String
}

extension FeatureStrings {
    static func timeTrackingEdit(_ language: AppLanguage) -> TimeTrackingEditStrings {
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

extension TimeTrackingEditStrings {
    static let enUS = TimeTrackingEditStrings(
        editTimes: "Edit Times", editStart: "Edit Start Time", addEntry: "Add Past Entry",
        startLabel: "Start", endLabel: "End", save: "Save", cancel: "Cancel",
        endBeforeStart: "The end must be after the start.", inFuture: "Times can’t be in the future.",
        overlaps: "This overlaps another entry.")
    static let ptBR = TimeTrackingEditStrings(
        editTimes: "Editar horários", editStart: "Editar horário de início", addEntry: "Adicionar registro anterior",
        startLabel: "Início", endLabel: "Fim", save: "Salvar", cancel: "Cancelar",
        endBeforeStart: "O fim precisa ser depois do início.", inFuture: "Os horários não podem estar no futuro.",
        overlaps: "Isto se sobrepõe a outro registro.")
    static let tr = TimeTrackingEditStrings(
        editTimes: "Saatleri Düzenle", editStart: "Başlangıç Saatini Düzenle", addEntry: "Geçmiş Kayıt Ekle",
        startLabel: "Başlangıç", endLabel: "Bitiş", save: "Kaydet", cancel: "Vazgeç",
        endBeforeStart: "Bitiş, başlangıçtan sonra olmalı.", inFuture: "Saatler gelecekte olamaz.",
        overlaps: "Bu, başka bir kayıtla çakışıyor.")
    static let ru = TimeTrackingEditStrings(
        editTimes: "Изменить время", editStart: "Изменить время начала", addEntry: "Добавить прошлую запись",
        startLabel: "Начало", endLabel: "Конец", save: "Сохранить", cancel: "Отменить",
        endBeforeStart: "Конец должен быть позже начала.", inFuture: "Время не может быть в будущем.",
        overlaps: "Это пересекается с другой записью.")
    static let es = TimeTrackingEditStrings(
        editTimes: "Editar horas", editStart: "Editar hora de inicio", addEntry: "Añadir registro pasado",
        startLabel: "Inicio", endLabel: "Fin", save: "Guardar", cancel: "Cancelar",
        endBeforeStart: "El fin debe ser posterior al inicio.", inFuture: "Las horas no pueden estar en el futuro.",
        overlaps: "Se solapa con otro registro.")
    static let sk = TimeTrackingEditStrings(
        editTimes: "Upraviť časy", editStart: "Upraviť čas začiatku", addEntry: "Pridať starší záznam",
        startLabel: "Začiatok", endLabel: "Koniec", save: "Uložiť", cancel: "Zrušiť",
        endBeforeStart: "Koniec musí byť po začiatku.", inFuture: "Časy nemôžu byť v budúcnosti.",
        overlaps: "Prekrýva sa s iným záznamom.")
    static let de = TimeTrackingEditStrings(
        editTimes: "Zeiten bearbeiten", editStart: "Startzeit bearbeiten", addEntry: "Früheren Eintrag hinzufügen",
        startLabel: "Start", endLabel: "Ende", save: "Sichern", cancel: "Abbrechen",
        endBeforeStart: "Das Ende muss nach dem Start liegen.",
        inFuture: "Zeiten dürfen nicht in der Zukunft liegen.",
        overlaps: "Das überschneidet sich mit einem anderen Eintrag.")
    static let fr = TimeTrackingEditStrings(
        editTimes: "Modifier les heures", editStart: "Modifier l’heure de début", addEntry: "Ajouter une entrée passée",
        startLabel: "Début", endLabel: "Fin", save: "Enregistrer", cancel: "Annuler",
        endBeforeStart: "La fin doit être après le début.",
        inFuture: "Les heures ne peuvent pas être dans le futur.",
        overlaps: "Cela chevauche une autre entrée.")
    static let it = TimeTrackingEditStrings(
        editTimes: "Modifica orari", editStart: "Modifica ora di inizio", addEntry: "Aggiungi registrazione passata",
        startLabel: "Inizio", endLabel: "Fine", save: "Salva", cancel: "Annulla",
        endBeforeStart: "La fine deve essere dopo l’inizio.", inFuture: "Gli orari non possono essere nel futuro.",
        overlaps: "Si sovrappone a un’altra registrazione.")
    static let ja = TimeTrackingEditStrings(
        editTimes: "時刻を編集", editStart: "開始時刻を編集", addEntry: "過去の記録を追加",
        startLabel: "開始", endLabel: "終了", save: "保存", cancel: "キャンセル",
        endBeforeStart: "終了は開始より後にしてください。", inFuture: "未来の時刻は指定できません。",
        overlaps: "ほかの記録と重なっています。")
    static let ko = TimeTrackingEditStrings(
        editTimes: "시간 편집", editStart: "시작 시간 편집", addEntry: "지난 기록 추가",
        startLabel: "시작", endLabel: "종료", save: "저장", cancel: "취소",
        endBeforeStart: "종료는 시작보다 뒤여야 합니다.", inFuture: "미래 시간은 지정할 수 없습니다.",
        overlaps: "다른 기록과 겹칩니다.")
    static let uk = TimeTrackingEditStrings(
        editTimes: "Змінити час", editStart: "Змінити час початку", addEntry: "Додати минулий запис",
        startLabel: "Початок", endLabel: "Кінець", save: "Зберегти", cancel: "Скасувати",
        endBeforeStart: "Кінець має бути пізніше за початок.", inFuture: "Час не може бути в майбутньому.",
        overlaps: "Це перетинається з іншим записом.")
    static let zhHans = TimeTrackingEditStrings(
        editTimes: "编辑时间", editStart: "编辑开始时间", addEntry: "添加过去的记录",
        startLabel: "开始", endLabel: "结束", save: "存储", cancel: "取消",
        endBeforeStart: "结束时间必须晚于开始时间。", inFuture: "时间不能在未来。",
        overlaps: "与另一条记录重叠。")
    static let zhTW = TimeTrackingEditStrings(
        editTimes: "編輯時間", editStart: "編輯開始時間", addEntry: "加入過去的記錄",
        startLabel: "開始", endLabel: "結束", save: "儲存", cancel: "取消",
        endBeforeStart: "結束時間必須晚於開始時間。", inFuture: "時間不能在未來。",
        overlaps: "與另一筆記錄重疊。")
    static let zhHK = TimeTrackingEditStrings(
        editTimes: "編輯時間", editStart: "編輯開始時間", addEntry: "加入過去的記錄",
        startLabel: "開始", endLabel: "結束", save: "儲存", cancel: "取消",
        endBeforeStart: "結束時間必須晚於開始時間。", inFuture: "時間不能在未來。",
        overlaps: "與另一筆記錄重疊。")
}
