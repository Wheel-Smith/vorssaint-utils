// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct TimeTrackingFeatureStrings {
    let title: String
    let tileCaption: String
    let hubDescription: String
    let descriptionPlaceholder: String
    let start: String
    let stop: String
    let recent: String
    let continueEntry: String
    let rename: String
    let delete: String
    let untitled: String
    let empty: String
    let emptyHint: String
    let showInMenuBar: String
    let saveFailed: String
}

extension FeatureStrings {
    static func timeTracking(_ language: AppLanguage) -> TimeTrackingFeatureStrings {
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

extension TimeTrackingFeatureStrings {
    static let enUS = TimeTrackingFeatureStrings(
        title: "Time Tracking", tileCaption: "Track what you work on",
        hubDescription: "Start named timers and see where your time went today and over the last 7 or 30 days",
        descriptionPlaceholder: "What are you working on?", start: "Start", stop: "Stop", recent: "Recent",
        continueEntry: "Continue", rename: "Rename", delete: "Delete", untitled: "Untitled",
        empty: "No time tracked yet", emptyHint: "Type what you’re working on and press Start.",
        showInMenuBar: "Show timer in menu bar", saveFailed: "Time entries couldn’t be saved.")
    static let ptBR = TimeTrackingFeatureStrings(
        title: "Registro de tempo", tileCaption: "Registre no que você trabalha",
        hubDescription: "Inicie cronômetros com nome e veja para onde foi seu tempo hoje e nos últimos 7 ou 30 dias",
        descriptionPlaceholder: "No que você está trabalhando?", start: "Iniciar", stop: "Parar", recent: "Recentes",
        continueEntry: "Continuar", rename: "Renomear", delete: "Apagar", untitled: "Sem título",
        empty: "Nenhum tempo registrado", emptyHint: "Digite no que está trabalhando e clique em Iniciar.",
        showInMenuBar: "Mostrar cronômetro na barra de menus", saveFailed: "Não foi possível salvar os registros de tempo.")
    static let tr = TimeTrackingFeatureStrings(
        title: "Zaman Takibi", tileCaption: "Ne üzerinde çalıştığınızı izleyin",
        hubDescription: "Adlandırılmış zamanlayıcılar başlatın ve zamanınızın bugün ve son 7 ya da 30 günde nereye gittiğini görün",
        descriptionPlaceholder: "Ne üzerinde çalışıyorsunuz?", start: "Başlat", stop: "Durdur", recent: "Son kullanılanlar",
        continueEntry: "Devam Et", rename: "Yeniden Adlandır", delete: "Sil", untitled: "Adsız",
        empty: "Henüz kaydedilen zaman yok", emptyHint: "Ne üzerinde çalıştığınızı yazıp Başlat’a basın.",
        showInMenuBar: "Zamanlayıcıyı menü çubuğunda göster", saveFailed: "Zaman kayıtları kaydedilemedi.")
    static let ru = TimeTrackingFeatureStrings(
        title: "Учёт времени", tileCaption: "Учёт времени по задачам",
        hubDescription: "Запускайте именованные таймеры и смотрите, на что ушло время сегодня и за последние 7 или 30 дней",
        descriptionPlaceholder: "Над чем вы работаете?", start: "Начать", stop: "Остановить", recent: "Недавние",
        continueEntry: "Продолжить", rename: "Переименовать", delete: "Удалить", untitled: "Без названия",
        empty: "Время ещё не учитывалось", emptyHint: "Введите, над чем работаете, и нажмите Начать.",
        showInMenuBar: "Показывать таймер в строке меню", saveFailed: "Не удалось сохранить записи времени.")
    static let es = TimeTrackingFeatureStrings(
        title: "Control de tiempo", tileCaption: "Registra en qué trabajas",
        hubDescription: "Inicia temporizadores con nombre y descubre a qué dedicaste el tiempo hoy y en los últimos 7 o 30 días",
        descriptionPlaceholder: "¿En qué estás trabajando?", start: "Iniciar", stop: "Detener", recent: "Recientes",
        continueEntry: "Continuar", rename: "Renombrar", delete: "Eliminar", untitled: "Sin título",
        empty: "Aún no hay tiempo registrado", emptyHint: "Escribe en qué estás trabajando y pulsa Iniciar.",
        showInMenuBar: "Mostrar temporizador en la barra de menús", saveFailed: "No se pudieron guardar los registros de tiempo.")
    static let sk = TimeTrackingFeatureStrings(
        title: "Sledovanie času", tileCaption: "Sledujte, na čom pracujete",
        hubDescription: "Spúšťajte pomenované časovače a pozrite sa, kam sa podel váš čas dnes a za posledných 7 alebo 30 dní",
        descriptionPlaceholder: "Na čom pracujete?", start: "Spustiť", stop: "Zastaviť", recent: "Nedávne",
        continueEntry: "Pokračovať", rename: "Premenovať", delete: "Vymazať", untitled: "Bez názvu",
        empty: "Zatiaľ žiadny zaznamenaný čas", emptyHint: "Napíšte, na čom pracujete, a stlačte Spustiť.",
        showInMenuBar: "Zobraziť časovač na lište menu", saveFailed: "Záznamy času sa nepodarilo uložiť.")
    static let de = TimeTrackingFeatureStrings(
        title: "Zeiterfassung", tileCaption: "Erfassen, woran du arbeitest",
        hubDescription: "Benannte Timer starten und sehen, wohin deine Zeit heute und in den letzten 7 oder 30 Tagen gegangen ist",
        descriptionPlaceholder: "Woran arbeitest du?", start: "Starten", stop: "Stoppen", recent: "Zuletzt",
        continueEntry: "Fortsetzen", rename: "Umbenennen", delete: "Löschen", untitled: "Ohne Titel",
        empty: "Noch keine Zeit erfasst", emptyHint: "Gib ein, woran du arbeitest, und klicke auf Starten.",
        showInMenuBar: "Timer in der Menüleiste zeigen", saveFailed: "Die Zeiteinträge konnten nicht gesichert werden.")
    static let fr = TimeTrackingFeatureStrings(
        title: "Suivi du temps", tileCaption: "Suivez ce sur quoi vous travaillez",
        hubDescription: "Lancez des minuteurs nommés et voyez où est passé votre temps aujourd’hui et sur les 7 ou 30 derniers jours",
        descriptionPlaceholder: "Sur quoi travaillez-vous\u{00A0}?", start: "Démarrer", stop: "Arrêter", recent: "Récents",
        continueEntry: "Reprendre", rename: "Renommer", delete: "Supprimer", untitled: "Sans titre",
        empty: "Aucun temps suivi pour l’instant", emptyHint: "Indiquez sur quoi vous travaillez et cliquez sur Démarrer.",
        showInMenuBar: "Afficher le minuteur dans la barre des menus", saveFailed: "Impossible d’enregistrer les entrées de temps.")
    static let it = TimeTrackingFeatureStrings(
        title: "Monitoraggio del tempo", tileCaption: "Registra ciò su cui lavori",
        hubDescription: "Avvia timer con un nome e scopri dove è finito il tuo tempo oggi e negli ultimi 7 o 30 giorni",
        descriptionPlaceholder: "A cosa stai lavorando?", start: "Avvia", stop: "Ferma", recent: "Recenti",
        continueEntry: "Riprendi", rename: "Rinomina", delete: "Elimina", untitled: "Senza titolo",
        empty: "Nessun tempo registrato", emptyHint: "Scrivi a cosa stai lavorando e premi Avvia.",
        showInMenuBar: "Mostra il timer nella barra dei menu", saveFailed: "Impossibile salvare le registrazioni del tempo.")
    static let ja = TimeTrackingFeatureStrings(
        title: "タイムトラッキング", tileCaption: "作業ごとに時間を記録",
        hubDescription: "名前付きのタイマーを開始して、今日と過去7日間または30日間の時間の使い方を確認できます",
        descriptionPlaceholder: "何に取り組んでいますか？", start: "開始", stop: "停止", recent: "最近",
        continueEntry: "続ける", rename: "名前を変更", delete: "削除", untitled: "名称未設定",
        empty: "まだ記録された時間はありません", emptyHint: "取り組んでいる内容を入力して開始を押してください。",
        showInMenuBar: "メニューバーにタイマーを表示", saveFailed: "時間の記録を保存できませんでした。")
    static let ko = TimeTrackingFeatureStrings(
        title: "시간 추적", tileCaption: "작업별로 시간 기록",
        hubDescription: "이름 있는 타이머를 시작하고 오늘과 지난 7일 또는 30일 동안 시간을 어디에 썼는지 확인합니다",
        descriptionPlaceholder: "무엇을 작업하고 있나요?", start: "시작", stop: "중지", recent: "최근",
        continueEntry: "계속", rename: "이름 변경", delete: "삭제", untitled: "제목 없음",
        empty: "아직 기록된 시간이 없습니다", emptyHint: "작업 중인 내용을 입력하고 시작을 누르세요.",
        showInMenuBar: "메뉴 막대에 타이머 표시", saveFailed: "시간 기록을 저장할 수 없습니다.")
    static let uk = TimeTrackingFeatureStrings(
        title: "Облік часу", tileCaption: "Облік часу за завданнями",
        hubDescription: "Запускайте іменовані таймери й дивіться, на що пішов час сьогодні та за останні 7 або 30 днів",
        descriptionPlaceholder: "Над чим ви працюєте?", start: "Почати", stop: "Зупинити", recent: "Нещодавні",
        continueEntry: "Продовжити", rename: "Перейменувати", delete: "Видалити", untitled: "Без назви",
        empty: "Час ще не обліковувався", emptyHint: "Введіть, над чим працюєте, і натисніть Почати.",
        showInMenuBar: "Показувати таймер у рядку меню", saveFailed: "Не вдалося зберегти записи часу.")
    static let zhHans = TimeTrackingFeatureStrings(
        title: "时间追踪", tileCaption: "按任务记录时间",
        hubDescription: "启动带名称的计时器，看看你今天以及过去 7 天或 30 天的时间都花在了哪里",
        descriptionPlaceholder: "你在做什么？", start: "开始", stop: "停止", recent: "最近",
        continueEntry: "继续", rename: "重命名", delete: "删除", untitled: "未命名",
        empty: "还没有记录任何时间", emptyHint: "输入你正在做的事情，然后点按开始。",
        showInMenuBar: "在菜单栏中显示计时器", saveFailed: "无法存储时间记录。")
    static let zhTW = TimeTrackingFeatureStrings(
        title: "時間追蹤", tileCaption: "依工作記錄時間",
        hubDescription: "啟動有名稱的計時器，看看你今天以及過去 7 天或 30 天的時間都花在哪裡",
        descriptionPlaceholder: "你在做什麼？", start: "開始", stop: "停止", recent: "最近",
        continueEntry: "繼續", rename: "重新命名", delete: "刪除", untitled: "未命名",
        empty: "尚未記錄任何時間", emptyHint: "輸入你正在做的事情，然後按一下開始。",
        showInMenuBar: "在選單列中顯示計時器", saveFailed: "無法儲存時間記錄。")
    static let zhHK = TimeTrackingFeatureStrings(
        title: "時間追蹤", tileCaption: "按工作記錄時間",
        hubDescription: "啟動有名稱的計時器，看看你今天以及過去 7 天或 30 天的時間都花在哪裡",
        descriptionPlaceholder: "你在做甚麼？", start: "開始", stop: "停止", recent: "最近",
        continueEntry: "繼續", rename: "重新命名", delete: "刪除", untitled: "未命名",
        empty: "尚未記錄任何時間", emptyHint: "輸入你正在做的事情，然後按一下開始。",
        showInMenuBar: "在選單列中顯示計時器", saveFailed: "無法儲存時間記錄。")
}
