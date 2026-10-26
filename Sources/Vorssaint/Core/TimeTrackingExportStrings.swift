// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// The CSV export: its button, its failure notice and the file's header row.
struct TimeTrackingExportStrings {
    let exportCSV: String
    let exportFailed: String
    let description: String
    let startDate: String
    let startTime: String
    let endDate: String
    let endTime: String
    let minutes: String

    var header: [String] { [description, startDate, startTime, endDate, endTime, minutes] }
}

extension FeatureStrings {
    static func timeTrackingExport(_ language: AppLanguage) -> TimeTrackingExportStrings {
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

extension TimeTrackingExportStrings {
    static let enUS = TimeTrackingExportStrings(
        exportCSV: "Export CSV…", exportFailed: "The CSV file couldn’t be saved.",
        description: "Description", startDate: "Start date", startTime: "Start time",
        endDate: "End date", endTime: "End time", minutes: "Minutes")
    static let ptBR = TimeTrackingExportStrings(
        exportCSV: "Exportar CSV…", exportFailed: "Não foi possível salvar o arquivo CSV.",
        description: "Descrição", startDate: "Data de início", startTime: "Hora de início",
        endDate: "Data de término", endTime: "Hora de término", minutes: "Minutos")
    static let tr = TimeTrackingExportStrings(
        exportCSV: "CSV Olarak Dışa Aktar…", exportFailed: "CSV dosyası kaydedilemedi.",
        description: "Açıklama", startDate: "Başlangıç tarihi", startTime: "Başlangıç saati",
        endDate: "Bitiş tarihi", endTime: "Bitiş saati", minutes: "Dakika")
    static let ru = TimeTrackingExportStrings(
        exportCSV: "Экспорт в CSV…", exportFailed: "Не удалось сохранить файл CSV.",
        description: "Описание", startDate: "Дата начала", startTime: "Время начала",
        endDate: "Дата окончания", endTime: "Время окончания", minutes: "Минуты")
    static let es = TimeTrackingExportStrings(
        exportCSV: "Exportar CSV…", exportFailed: "No se pudo guardar el archivo CSV.",
        description: "Descripción", startDate: "Fecha de inicio", startTime: "Hora de inicio",
        endDate: "Fecha de fin", endTime: "Hora de fin", minutes: "Minutos")
    static let sk = TimeTrackingExportStrings(
        exportCSV: "Exportovať CSV…", exportFailed: "Súbor CSV sa nepodarilo uložiť.",
        description: "Popis", startDate: "Dátum začiatku", startTime: "Čas začiatku",
        endDate: "Dátum konca", endTime: "Čas konca", minutes: "Minúty")
    static let de = TimeTrackingExportStrings(
        exportCSV: "Als CSV exportieren…", exportFailed: "Die CSV-Datei konnte nicht gesichert werden.",
        description: "Beschreibung", startDate: "Startdatum", startTime: "Startzeit",
        endDate: "Enddatum", endTime: "Endzeit", minutes: "Minuten")
    static let fr = TimeTrackingExportStrings(
        exportCSV: "Exporter en CSV…", exportFailed: "Impossible d’enregistrer le fichier CSV.",
        description: "Description", startDate: "Date de début", startTime: "Heure de début",
        endDate: "Date de fin", endTime: "Heure de fin", minutes: "Minutes")
    static let it = TimeTrackingExportStrings(
        exportCSV: "Esporta CSV…", exportFailed: "Impossibile salvare il file CSV.",
        description: "Descrizione", startDate: "Data di inizio", startTime: "Ora di inizio",
        endDate: "Data di fine", endTime: "Ora di fine", minutes: "Minuti")
    static let ja = TimeTrackingExportStrings(
        exportCSV: "CSVを書き出す…", exportFailed: "CSVファイルを保存できませんでした。",
        description: "説明", startDate: "開始日", startTime: "開始時刻",
        endDate: "終了日", endTime: "終了時刻", minutes: "分")
    static let ko = TimeTrackingExportStrings(
        exportCSV: "CSV 내보내기…", exportFailed: "CSV 파일을 저장할 수 없습니다.",
        description: "설명", startDate: "시작 날짜", startTime: "시작 시간",
        endDate: "종료 날짜", endTime: "종료 시간", minutes: "분")
    static let uk = TimeTrackingExportStrings(
        exportCSV: "Експорт у CSV…", exportFailed: "Не вдалося зберегти файл CSV.",
        description: "Опис", startDate: "Дата початку", startTime: "Час початку",
        endDate: "Дата завершення", endTime: "Час завершення", minutes: "Хвилини")
    static let zhHans = TimeTrackingExportStrings(
        exportCSV: "导出 CSV…", exportFailed: "无法存储 CSV 文件。",
        description: "描述", startDate: "开始日期", startTime: "开始时间",
        endDate: "结束日期", endTime: "结束时间", minutes: "分钟")
    static let zhTW = TimeTrackingExportStrings(
        exportCSV: "輸出 CSV…", exportFailed: "無法儲存 CSV 檔案。",
        description: "描述", startDate: "開始日期", startTime: "開始時間",
        endDate: "結束日期", endTime: "結束時間", minutes: "分鐘")
    static let zhHK = TimeTrackingExportStrings(
        exportCSV: "輸出 CSV…", exportFailed: "無法儲存 CSV 檔案。",
        description: "描述", startDate: "開始日期", startTime: "開始時間",
        endDate: "結束日期", endTime: "結束時間", minutes: "分鐘")
}
