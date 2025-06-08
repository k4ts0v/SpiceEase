// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmación de contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get createAccount => 'Crear nueva cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get sessionExpired => 'Sesión caducada. Por favor inicia sesión nuevamente.';

  @override
  String get rememberMe => 'Recuérdame';

  @override
  String get recoveryEmailSent => 'Se ha enviado un correo de recuperación.';

  @override
  String get invalidLoginCredentials => 'Las credenciales son incorrectas.';

  @override
  String get wrongPassword => 'Las credenciales son incorrectas.';

  @override
  String get userNotFound => 'Las credenciales son incorrectas.';

  @override
  String get emailAlreadyInUse => 'Este correo ya está registrado. Prueba a iniciar sesión.';

  @override
  String get missingPassword => 'Introduce tu contraseña.';

  @override
  String get passwordMismatch => 'Las contraseñas no son iguales.';

  @override
  String get invalidEmail => 'Introduce una dirección de correo válida.';

  @override
  String get passwordReset => 'Reseteo de contraseña';

  @override
  String get emailHint => 'Introduce tu email.';

  @override
  String get resetEmail => 'Enviar email de recuperación.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get passwordResetEmail => 'El correo de recuperación de contraseña se ha enviado.';

  @override
  String get resetPasswordError => 'Ha ocurrido un error al resetear la contraseña.';

  @override
  String get unknownError => 'Ha ocurrido un error desconocido.';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get username_required => 'Es necesario introducir un nombre de usuario.';

  @override
  String get symptom => 'Síntoma';

  @override
  String get symptoms => 'Síntomas';

  @override
  String get task => 'Tarea';

  @override
  String get tasks => 'Tareas';

  @override
  String get habit => 'Hábito';

  @override
  String get habits => 'Hábitos';

  @override
  String get category => 'Categoría';

  @override
  String get severity => 'Severidad';

  @override
  String get due => 'Fecha límite';

  @override
  String get status => 'Estado';

  @override
  String get noDueDate => 'Sin fecha límite';

  @override
  String get noTimeEstimate => 'Sin estimación de tiempo';

  @override
  String get done => 'Hecho';

  @override
  String get pending => 'Pendiente';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthlyDays => 'Mensual (días)';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get title => 'Título';

  @override
  String get additionalText => 'Texto adicional';

  @override
  String get noItemsYet => 'Aún no hay elementos';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String deleteConfirmationMessage(Object item) {
    return '¿Estás seguro de que deseas eliminar \"$item\"?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get calendarFirstDay => 'Primer día';

  @override
  String get calendarLastDay => 'Último día';

  @override
  String get calendarMonday => 'Lunes';

  @override
  String get calendarToday => 'Hoy';

  @override
  String get calendarSelectedDay => 'Día seleccionado';

  @override
  String get calendarStyleHeaderTitle => 'Título del encabezado del calendario';

  @override
  String get calendarStyleHeaderFormatButtonVisible => 'Botón de formato visible';

  @override
  String get calendarStyleHeaderTitleCentered => 'Título del encabezado centrado';

  @override
  String get calendarStyleDaysOfWeek => 'Días de la semana';

  @override
  String editTitle(Object item) {
    return 'Editar $item';
  }

  @override
  String newTitle(Object item) {
    return 'Nueva entrada para $item';
  }

  @override
  String deleteConfirmationTitle(Object item) {
    return 'Eliminar $item?';
  }

  @override
  String get save => 'Guardar';

  @override
  String get name => 'Nombre';

  @override
  String get customCategory => 'Categoría personalizada';

  @override
  String requiredField(Object field) {
    return '$field es obligatorio';
  }

  @override
  String get monthly => 'Mensual';

  @override
  String get dayOfMonth => 'Día del mes (1-31)';

  @override
  String pleaseSelectA(Object field) {
    return 'Por favor selecciona al menos un $field';
  }

  @override
  String get addDayOfMonth => 'Agregar día del mes';

  @override
  String get markAsCompleted => 'Marcar como completado';

  @override
  String get description => 'Descripción';

  @override
  String get priority => 'Prioridad';

  @override
  String dueDate(Object date) {
    return 'Fecha de vencimiento: $date';
  }

  @override
  String get noDueDateSet => 'No se ha establecido una fecha de vencimiento';

  @override
  String get setDueDate => 'Establecer fecha';

  @override
  String completedAt(Object date) {
    return 'Completado: $date';
  }

  @override
  String get notCompleted => 'No completado';

  @override
  String get setCompleted => 'Establecer como completado';

  @override
  String get estimate => 'Estimar';

  @override
  String estimatedTime(Object time) {
    return 'Tiempo estimado: $time';
  }

  @override
  String get generateSubtasks => 'Divídelo en subtareas';

  @override
  String get generatingSubtasks => 'Generando subtareas...';

  @override
  String get noSubtasksGenerated => 'No se generaron subtareas';

  @override
  String failedToGenerateSubtasks(Object error) {
    return 'Error al generar subtareas: $error';
  }

  @override
  String get completed => 'Completado';

  @override
  String get notes => 'Notas';

  @override
  String get timesPerDay => 'Veces al día';

  @override
  String get customTimes => 'Veces personalizadas';

  @override
  String get dose => 'Dosis';

  @override
  String get customUnit => 'Unidad personalizada';

  @override
  String get unit => 'Unidad';

  @override
  String get markAsTaken => 'Marcar como tomado';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get physical => 'Físico';

  @override
  String get psychological => 'Psicológico';

  @override
  String get custom => 'Personalizado';

  @override
  String get thisSymptom => 'este síntoma';

  @override
  String get titleRequired => 'El título es obligatorio';

  @override
  String get enterDayOfMonth => 'Ingrese el día del mes (1-31)';

  @override
  String get dayOfMonthHint => 'ej., 1, 15, 31';

  @override
  String dayNumber(Object number) {
    return 'Día $number';
  }

  @override
  String get selectWeekday => 'Seleccione al menos un día de la semana';

  @override
  String get selectDayOfMonth => 'Seleccione al menos un día del mes';

  @override
  String get thisHabit => 'este hábito';

  @override
  String get thisTask => 'esta tarea';

  @override
  String get breakIntoSubtasks => 'Dividir en subtareas';

  @override
  String get breakIntoSubtasksPrompt => '¿Quieres dividir esta tarea en subtareas?';

  @override
  String get subtask => 'Subtarea';

  @override
  String get subtasks => 'Subtareas';

  @override
  String subtaskFor(Object taskTitle) {
    return 'Subtarea de: $taskTitle';
  }

  @override
  String currentEstimate(Object time, Object unit) {
    return 'Estimación actual: $time $unit';
  }

  @override
  String get mood => 'Estado de ánimo';

  @override
  String get thisMoodEntry => 'este registro de ánimo';

  @override
  String get energy => 'Energía';

  @override
  String get thisEnergyEntry => 'esta entrada de energía';

  @override
  String get selectMoodLevel => 'Selecciona nivel de ánimo';

  @override
  String get moodLevelScale => '1 = Muy bajo, 10 = Excelente';

  @override
  String get medication => 'Medicación';

  @override
  String get thisMedication => 'esta medicación';

  @override
  String get doseRequired => 'La dosis es obligatoria';

  @override
  String get customValue => 'Valor personalizado';

  @override
  String get enterDayHint => 'Ingrese un número y presione Añadir';

  @override
  String get addDay => 'Añadir día';

  @override
  String get selectAtLeastOneDay => 'Por favor seleccione al menos un día';

  @override
  String minutesAbbreviation(Object value) {
    return '$value min';
  }

  @override
  String get estimatedTimeLabel => 'Tiempo estimado';

  @override
  String get titleRequiredForSubtasks => 'El título es obligatorio para las subtareas';

  @override
  String get addNew => 'Añadir nuevo';

  @override
  String get additionalNotes => 'Notas adicionales';

  @override
  String get timeManagement => 'Gestión del Tiempo';

  @override
  String get kanban => 'Kanban';

  @override
  String get kanbanDescription => 'Visualiza tu flujo de trabajo con tarjetas organizadas en columnas para seguir el progreso.';

  @override
  String get timeBlocks => 'Bloques de Tiempo';

  @override
  String get timeBlocksDescription => 'Programa tu día en bloques de tiempo dedicados para aumentar el enfoque y la productividad.';

  @override
  String get flowmodoro => 'Flowmodoro';

  @override
  String get flowmodoroDescription => 'Trabaja mientras te sientas productivo, luego recarga energías con un descanso proporcional.';

  @override
  String get noTasksInThisColumn => 'No hay tareas en esta columna';

  @override
  String get inProgress => 'En progreso';

  @override
  String get todo => 'Por hacer';

  @override
  String get error => 'Error';

  @override
  String get tasksWithoutDueDate => 'Tareas sin fecha límite';

  @override
  String get noTasksWithoutDueDate => 'No hay tareas sin fecha límite';

  @override
  String get noTasks => 'No hay tareas';

  @override
  String get unitsTaken => 'Unidades tomadas hoy';

  @override
  String unitTakenOf(Object taken, Object total) {
    return '$taken de $total tomadas';
  }

  @override
  String get taken => 'Tomadas';

  @override
  String get takenS => 'Tomada';

  @override
  String get notTaken => 'Sin tomar';

  @override
  String get refresh => 'Actualizar';

  @override
  String errorSavingTask(Object error) {
    return 'Error guardando la tarea: $error';
  }

  @override
  String get home => 'Inicio';

  @override
  String get settings => 'Ajustes';

  @override
  String get insights => 'Reportes';

  @override
  String get profile => 'Perfil';

  @override
  String get dragTasksHere => 'Arrastra tareas aquí';

  @override
  String get lowestPriority => 'Prioridad más baja';

  @override
  String get lowPriority => 'Prioridad baja';

  @override
  String get mediumPriority => 'Prioridad media';

  @override
  String get highPriority => 'Prioridad alta';

  @override
  String get highestPriority => 'Prioridad más alta';

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get loading => 'Cargando...';

  @override
  String get initializationError => 'Error de inicialización';

  @override
  String get close => 'Cerrar';

  @override
  String get clearCompletion => 'Eliminar finalización';

  @override
  String get tablets => 'Comprimidos';

  @override
  String get second => 'segundo';

  @override
  String get seconds => 'segundos';

  @override
  String get minute => 'minuto';

  @override
  String get minutes => 'minutos';

  @override
  String get hour => 'hora';

  @override
  String get hours => 'horas';

  @override
  String get day => 'día';

  @override
  String get days => 'días';

  @override
  String get week => 'semana';

  @override
  String get weeks => 'semanas';

  @override
  String get month => 'mes';

  @override
  String get months => 'meses';

  @override
  String get year => 'año';

  @override
  String get estimateInstructions => 'Da la estimación en números. Para rangos de números, sepáralos usando \'a\'.';

  @override
  String get allTasksScheduled => 'Todas las tareas están programadas';

  @override
  String get unscheduledTasks => 'Tareas no programadas';

  @override
  String get unschedule => 'Desprogramar';

  @override
  String get unscheduleTaskConfirmation => '¿Deseas eliminar esta tarea de la agenda? Permanecerá en tu lista de tareas.';

  @override
  String get noEndTime => 'Sin hora de finalización';

  @override
  String get setEndTime => 'Establecer hora de finalización';

  @override
  String get setStartTime => 'Establecer hora de inicio';

  @override
  String get startTime => 'Hora de inicio';

  @override
  String get noStartTime => 'Sin hora de inicio';

  @override
  String get endTime => 'Hora de finalización';

  @override
  String get clear => 'Limpia';

  @override
  String get selectTaskForFlowmodoro => 'Seleccionar una tarea para flowmodoro';

  @override
  String get flowmodoroExplanation => 'Concéntrate en una tarea a la vez con intervalos de trabajo y descanso';

  @override
  String get selectATaskToStart => 'Selecciona una tarea para comenzar';

  @override
  String get configureFlowmodoro => 'Configurar flowmodoro';

  @override
  String get focusTime => 'Tiempo de concentración';

  @override
  String get breakTime => 'Tiempo de descanso';

  @override
  String get cyclesToComplete => 'Ciclos a completar';

  @override
  String get cycles => 'ciclos';

  @override
  String get startFlowmodoro => 'Iniciar flowmodoro';

  @override
  String get stopFlowmodoro => 'Detener flowmodoro';

  @override
  String get flowmodoroCompleted => 'Flowmodoro completado';

  @override
  String get markTaskAsCompleted => '¿Deseas marcar esta tarea como completada?';

  @override
  String get notYet => 'Aún No';

  @override
  String get markAsDone => 'Marcar como completada';

  @override
  String get taskMarkedAsCompleted => 'Tarea marcada como completada';

  @override
  String get cycleProgress => 'Ciclo \$1 de \$2';

  @override
  String get relax => 'Relájate';

  @override
  String get focus => 'Concéntrate';

  @override
  String get noTasksAvailable => 'No hay tareas disponibles';

  @override
  String errorMarkingTaskComplete(Object error) {
    return 'Error marcando la tarea como completada: $error';
  }

  @override
  String get breakTimeEnded => 'Tiempo de descanso terminado';

  @override
  String get focusTimeEnded => 'Tiempo de concentración terminado';

  @override
  String get timeToFocusAgain => '¡Es hora de volver a concentrarte en tu tarea!';

  @override
  String get timeToTakeABreak => '¡Buen trabajo! Es hora de tomar un breve descanso.';

  @override
  String get gotIt => 'Entendido';

  @override
  String get errorLoadingSubtasks => 'Error cargando las subtareas: ';

  @override
  String get noSubtasks => 'No hay subtareas';

  @override
  String get thisSubtask => 'esta subtarea';

  @override
  String get subtaskTitle => 'Título de la subtarea';

  @override
  String get addNewSubtask => 'Agregar una subtarea';

  @override
  String get speedrun => 'Speedrun';

  @override
  String get speedrunDescription => 'Ponte a prueba completando tareas en un tiempo limitado. Cuanto más rápido termines, más puntos ganarás.';

  @override
  String get diceRoller => 'Lanzador de dados';

  @override
  String get diceRollerDescription => 'Tira un dado para generar números aleatorios para tus tareas. Úsalo para saber cuántos elementos tienes que completar.';

  @override
  String get metricsOverTime => 'Métricas a lo largo del tiempo';

  @override
  String get noDataForPeriod => 'No hay datos para este período';

  @override
  String get streaks => 'Rachas';

  @override
  String longestTasksStreak(Object days) {
    return 'Racha más larga de tareas: $days días';
  }

  @override
  String longestHabitsStreak(Object days) {
    return 'Racha más larga de hábitos: $days días';
  }

  @override
  String get timeManagementTechniques => 'Técnicas de gestión del tiempo';

  @override
  String get flowmodoroInsights => 'Estadísticas de Flowmodoro';

  @override
  String sessions(Object count) {
    return 'Sesiones: $count';
  }

  @override
  String combinedTime(Object time) {
    return 'Tiempo combinado: $time';
  }

  @override
  String get timeBlockInsights => 'Estadísticas de bloques de tiempo';

  @override
  String get blocks => 'Bloques';

  @override
  String get time => 'Tiempo';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get language => 'Idioma';

  @override
  String get notificationSettings => 'Configuración de notificaciones';

  @override
  String get comingSoon => 'Disponible pronto';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Contraseña nueva';

  @override
  String get security => 'Seguridad';

  @override
  String get incompleteSubtasksWarning => 'Algunas subtareas aún no se han completado.';

  @override
  String get generalSettings => 'Configuración General';

  @override
  String get enableNotifications => 'Activar Notificaciones';

  @override
  String get sound => 'Sonido';

  @override
  String get vibration => 'Vibración';

  @override
  String get historyRetention => 'Retención del Historial';

  @override
  String daysOfHistory(String days) {
    return '$days días';
  }

  @override
  String get contextAwareness => 'Sensibilidad al contexto';

  @override
  String get alwaysShowCritical => 'Mostrar siempre notificaciones críticas';

  @override
  String get alwaysShowCriticalDescription => 'Las notificaciones críticas se mostrarán independientemente de los niveles de energía o síntomas';

  @override
  String get lowEnergyThreshold => 'Umbral de energía baja';

  @override
  String get lowEnergyDescription => 'Cuando tu energía esté por debajo de este nivel, solo se mostrarán notificaciones de alta prioridad';

  @override
  String get highSymptomThreshold => 'Umbral de síntomas altos';

  @override
  String get highSymptomDescription => 'Cuando tus síntomas estén por encima de este nivel, solo se mostrarán notificaciones críticas';

  @override
  String get quietHours => 'Horas de Silencio';

  @override
  String get enableQuietHours => 'Activar horas de silencio';

  @override
  String get quietHoursStart => 'Hora de inicio';

  @override
  String get quietHoursEnd => 'Hora de fin';

  @override
  String get notificationCategories => 'Categorías de notificaciones';

  @override
  String get appointments => 'Citas';

  @override
  String get system => 'Sistema';

  @override
  String get notificationHistory => 'Historial de Notificaciones';

  @override
  String get errorLoadingNotifications => 'Error al cargar notificaciones';

  @override
  String get noNotificationsYet => 'No hay notificaciones todavía';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get configureNotificationPreferences => 'Configura cómo y cuándo aparecen las notificaciones';

  @override
  String get viewPastNotifications => 'Ver notificaciones recibidas anteriormente';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get loggingReminders => 'Recordatorios de registro';

  @override
  String get reminderSettings => 'Configuración de Recordatorios';

  @override
  String get reminderTime => 'Hora del Recordatorio';

  @override
  String get reminderDays => 'Días del Recordatorio';

  @override
  String get dailyReminder => 'Recordatorio diario';

  @override
  String get taskReminderDescription => 'Recordatorio diario para revisar tareas pendientes';

  @override
  String get habitReminderDescription => 'Recordatorio diario para verifica el progreso de hábitos';

  @override
  String get medicationReminderDescription => 'Recordatorio diario para tomar medicamentos';

  @override
  String get symptomReminderDescription => 'Recordatorio diario para registrar síntomas';

  @override
  String get energyReminderDescription => 'Recordatorio diario para registrar niveles de energía';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mié';

  @override
  String get thursday => 'Jue';

  @override
  String get friday => 'Vie';

  @override
  String get saturday => 'Sáb';

  @override
  String get sunday => 'Dom';

  @override
  String get loggingRemindersDescription => 'Daily reminders to log your health data';

  @override
  String get categoryReminders => 'Category Reminders';

  @override
  String get categoryRemindersDescription => 'Set up daily reminders for each type of data you want to track';

  @override
  String get specificItemReminders => 'Specific Item Reminders';

  @override
  String get specificItemRemindersDescription => 'Allow setting reminders for individual tasks, habits, and medications';

  @override
  String get enableSpecificRemindersFor => 'Enable specific reminders for:';

  @override
  String get notificationCategoriesDescription => 'Choose which types of notifications you want to receive';

  @override
  String get taskSpecificRemindersDescription => 'Set due date reminders for individual tasks';

  @override
  String get habitSpecificRemindersDescription => 'Set time-based reminders for individual habits';

  @override
  String get medicationSpecificRemindersDescription => 'Set medication time reminders';

  @override
  String get specificRemindersDescription => 'Establecer recordatorios individuales';

  @override
  String thisItem(String itemName) {
    return 'este $itemName';
  }

  @override
  String item(String itemName) {
    return '$itemName';
  }

  @override
  String failedToSaveItem(String itemName) {
    return 'Error al guardar $itemName';
  }

  @override
  String failedToDeleteItem(String itemName) {
    return 'Error al eliminar $itemName';
  }

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get themeMode => 'Modo de Tema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightThemeDesc => 'Usar siempre el tema claro';

  @override
  String get darkThemeDesc => 'Usar siempre el tema oscuro';

  @override
  String get systemThemeDesc => 'Seguir configuración del sistema';

  @override
  String get customizeAppColors => 'Personalizar colores de la app';

  @override
  String get toggleDarkMode => 'Alternar modo oscuro';

  @override
  String get languageAndRegion => 'Idioma y Región';

  @override
  String get languageChangedTo => 'Idioma cambiado a';

  @override
  String get systemDefault => 'Predeterminado del Sistema';

  @override
  String get dataAndPrivacy => 'Datos y Privacidad';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get exportImportData => 'Exportar, importar y respaldar datos';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacySettings => 'Configuración de privacidad y uso de datos';

  @override
  String get supportAndInfo => 'Soporte e Información';

  @override
  String get help => 'Ayuda';

  @override
  String get faqAndSupport => 'Preguntas frecuentes y soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get appInfo => 'Información de la app y créditos';

  @override
  String get version => 'Versión';

  @override
  String get buildNumber => 'Número de Compilación';

  @override
  String get developer => 'Desarrollador';

  @override
  String get website => 'Sitio Web';

  @override
  String get sourceCode => 'Código Fuente';

  @override
  String get licenses => 'Licencias';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get contact => 'Contacto';

  @override
  String get reportBug => 'Reportar un Error';

  @override
  String get requestFeature => 'Solicitar una Función';

  @override
  String get rateApp => 'Calificar la App';

  @override
  String get shareApp => 'Compartir la App';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get importData => 'Importar Datos';

  @override
  String get backupData => 'Respaldar Datos';

  @override
  String get restoreData => 'Restaurar Datos';

  @override
  String get clearData => 'Limpia Datos';

  @override
  String get clearDataWarning => 'Esto eliminará permanentemente todos tus datos. Esta acción no se puede deshacer.';

  @override
  String get clearDataConfirm => '¿Estás seguro de que quieres limpiar todos los datos?';

  @override
  String get confirm => 'Confirmar';

  @override
  String get dataExported => 'Datos exportados exitosamente';

  @override
  String get dataImported => 'Datos importados exitosamente';

  @override
  String get dataBackedUp => 'Datos respaldados exitosamente';

  @override
  String get dataRestored => 'Datos restaurados exitosamente';

  @override
  String get dataCleared => 'Datos limpiados exitosamente';

  @override
  String get exportFailed => 'Error al exportar datos';

  @override
  String get importFailed => 'Error al importar datos';

  @override
  String get backupFailed => 'Error al respaldar datos';

  @override
  String get restoreFailed => 'Error al restaurar datos';

  @override
  String get clearFailed => 'Error al limpiar datos';

  @override
  String get selectFile => 'Seleccionar Archivo';

  @override
  String get noFileSelected => 'Ningún archivo seleccionado';

  @override
  String get invalidFile => 'Formato de archivo inválido';

  @override
  String get permissionDenied => 'Permiso denegado';

  @override
  String get storagePermissionRequired => 'Se requiere permiso de almacenamiento para exportar/importar datos';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String get dataProtection => 'Protección de datos';

  @override
  String get dataProtectionDesc => 'Tus datos se almacenan localmente en tu dispositivo y no se comparten con terceros';

  @override
  String get analytics => 'Análisis';

  @override
  String get analyticsDesc => 'Ayuda a mejorar la app enviando datos de uso anónimos';

  @override
  String get crashReporting => 'Reporte de errores';

  @override
  String get crashReportingDesc => 'Enviar reportes de errores para ayudar a corregir bugs';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get frequentlyAskedQuestions => 'Preguntas frecuentes';

  @override
  String get howToUse => 'Cómo Usar';

  @override
  String get tutorials => 'Tutoriales';

  @override
  String get keyboardShortcuts => 'Atajos de teclado';

  @override
  String get tips => 'Consejos y Trucos';

  @override
  String get troubleshooting => 'Solución de problemas';

  @override
  String get commonIssues => 'Problemas comunes';

  @override
  String get contactSupport => 'Contactar con soporte';

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get tracker => 'Tracker';

  @override
  String get appCrashesOrFreezes => 'La app se cierra o se congela';

  @override
  String get appCrashesDescription => 'La aplicación deja de responder o se cierra inesperadamente';

  @override
  String get dataSyncIssues => 'Los datos no se sincronizan';

  @override
  String get dataSyncDescription => 'Los cambios no se guardan o faltan datos';

  @override
  String get performanceIssues => 'Problemas de rendimiento';

  @override
  String get performanceDescription => 'La aplicación funciona lentamente o tarda en cargar';

  @override
  String get timerNotWorking => 'Timer not working';

  @override
  String get timerDescription => 'Flowmodoro or other timers aren\'t functioning properly';

  @override
  String get tryTheseSolutions => 'Prueba estas soluciones:';

  @override
  String get stillHavingIssues => '¿Sigues teniendo problemas? Contacta al soporte para ayuda personalizada.';

  @override
  String get forceCloseRestart => 'Fuerza el cierre y reinicia la aplicación';

  @override
  String get restartDevice => 'Reinicia tu dispositivo';

  @override
  String get checkStorageSpace => 'Verifica que tengas suficiente espacio de almacenamiento (necesitas al menos 100MB libres)';

  @override
  String get updateApp => 'Actualiza a la última versión de la aplicación';

  @override
  String get clearAppCache => 'Limpia caché de la aplicación en configuración del dispositivo';

  @override
  String get uninstallReinstall => 'Desinstala y reinstalar la aplicación';

  @override
  String get checkInternetConnection => 'Verifica que tienes conexión a internet';

  @override
  String get checkCorrectDate => 'Verifica que estés viendo la fecha correcta';

  @override
  String get ensureNoFilters => 'Asegúrate de que no hay filtros aplicados que puedan ocultar tus datos';

  @override
  String get forceCloseReopen => 'Fuerza el cierre y reabre la aplicación';

  @override
  String get tryLoggingAgain => 'Intenta registrar los mismos datos nuevamente';

  @override
  String get closeBackgroundApps => 'Cierra otras aplicaciones ejecutándose en segundo plano';

  @override
  String get clearOldData => 'Limpia datos antiguos que ya no necesites (Configuración > Gestión de Datos)';

  @override
  String get checkAvailableStorage => 'Verifica el espacio de almacenamiento disponible';

  @override
  String get unableToLoadVersionInfo => 'No se puede cargar la información de la versión';

  @override
  String get viewOnGitHub => 'Ver en GitHub';

  @override
  String get reportBugsOnGitHub => 'Informar de errores y problemas en GitHub';

  @override
  String get suggestFeaturesOnGitHub => 'Sugerir nuevas características en GitHub';

  @override
  String get bugReport => 'Informe de error';

  @override
  String get featureRequest => 'Feature Request';

  @override
  String get create => 'Crear';

  @override
  String unableToOpenGitHubAutomatically(String issueType) {
    return 'No se puede abrir GitHub automáticamente. Copia este enlace para crear un $issueType con una plantilla pre-rellenada:';
  }

  @override
  String get gitHubIssueUrlCopied => 'URL de incidencia de GitHub copiada en el portapapeles';

  @override
  String get copyUrl => 'URL copiada';

  @override
  String get openLink => 'Abrir enlace';

  @override
  String get unableToOpenLinkAutomatically => 'No se puede abrir el enlace automáticamente. Copie este enlace y ábralo en su navegador:';

  @override
  String get urlCopied => 'URL copiada en el portapapeles';

  @override
  String get unableToShowLicenses => 'Imposible mostrar licencias en este momento';

  @override
  String get ok => 'OK';

  @override
  String get bugReportTitle => 'Reporte de Error';

  @override
  String get featureRequestTitle => 'Solicitud de Función';

  @override
  String get describeTheBug => 'Describe el error';

  @override
  String get bugDescription => 'Una descripción clara y concisa de cuál es el error.';

  @override
  String get toReproduce => 'Para Reproducir';

  @override
  String get stepsToReproduce => 'Pasos para reproducir el comportamiento';

  @override
  String get stepGoTo => 'Ir a \'...\'';

  @override
  String get stepClickOn => 'Hacer clic en \'....\'';

  @override
  String get stepScrollTo => 'Desplazarse hacia abajo a \'....\'';

  @override
  String get stepSeeError => 'Ver error';

  @override
  String get expectedBehavior => 'Comportamiento esperado';

  @override
  String get expectedBehaviorDescription => 'Una descripción clara y concisa de lo que esperabas que pasara.';

  @override
  String get screenshots => 'Capturas de pantalla';

  @override
  String get screenshotsDescription => 'Si es aplicable, agrega capturas de pantalla para ayudar a explicar tu problema.';

  @override
  String get deviceInformation => 'Información del Dispositivo';

  @override
  String get device => 'Dispositivo';

  @override
  String get operatingSystem => 'SO';

  @override
  String get appVersion => 'Versión de la App';

  @override
  String get unknown => 'Desconocido';

  @override
  String get additionalContext => 'Contexto adicional';

  @override
  String get additionalContextDescription => 'Agrega cualquier otro contexto sobre el problema aquí.';

  @override
  String get featureRequestProblem => '¿Tu solicitud de función está relacionada con un problema? Por favor describe.';

  @override
  String get featureRequestProblemDescription => 'Una descripción clara y concisa de cuál es el problema. Ej. Siempre me frustra cuando [...]';

  @override
  String get describeSolution => 'Describe la solución que te gustaría';

  @override
  String get describeSolutionDescription => 'Una descripción clara y concisa de lo que quieres que pase.';

  @override
  String get describeAlternatives => 'Describe alternativas que has considerado';

  @override
  String get describeAlternativesDescription => 'Una descripción clara y concisa de cualquier solución alternativa o función que hayas considerado.';

  @override
  String get featureAdditionalContext => 'Agrega cualquier otro contexto o capturas de pantalla sobre la solicitud de función aquí.';

  @override
  String get useCase => 'Caso de Uso';

  @override
  String get useCaseDescription => 'Describe cómo se usaría esta función y quién se beneficiaría de ella.';

  @override
  String get faqCategoryGettingStarted => 'Primeros Pasos';

  @override
  String get faqCategoryTimeManagement => 'Gestión del Tiempo';

  @override
  String get faqCategoryHealthTracking => 'Seguimiento de Salud';

  @override
  String get faqCategoryDataPrivacy => 'Datos y Privacidad';

  @override
  String get faqCategoryTroubleshooting => 'Solución de Problemas';

  @override
  String get faqHowCreateFirstTask => '¿Cómo creo mi primera tarea?';

  @override
  String get faqHowCreateFirstTaskAnswer => 'Toca el botón \"+\" en la pantalla principal del tracker, selecciona \"Tarea\", llena los detalles y toca \"Guardar\". Puedes agregar un título, descripción, fecha de vencimiento y prioridad. Las subtareas se generan automáticamente basándose en la descripción de tu tarea, pero puedes agregar más presionando el botón de agregar en la lista, debajo de la última subtarea.';

  @override
  String get faqDifferenceTasksHabits => '¿Cuál es la diferencia entre tareas y hábitos?';

  @override
  String get faqDifferenceTasksHabitsAnswer => 'Las tareas son actividades únicas con fechas límite específicas, mientras que los hábitos son actividades recurrentes que quieres hacer regularmente (diario, semanal, etc.). Los hábitos ayudan a construir rutinas a largo plazo.';

  @override
  String get faqEnergyTrackingTasks => '¿Cómo afecta el seguimiento de energía a mis tareas?';

  @override
  String get faqEnergyTrackingTasksAnswer => 'Tu nivel de energía (rastreado diariamente del 1-10) es usado por la IA de la app para proporcionar una gestión de tareas más inteligente. Niveles de energía más altos resultan en duraciones estimadas más largas y desgloses de subtareas más detallados, ya que la app asume que puedes manejar trabajo más complejo. Niveles de energía más bajos llevan a tareas más cortas y simples para coincidir con tu capacidad. Esto ayuda a asegurar que tu planificación diaria sea realista basada en cómo te sientes realmente.';

  @override
  String get faqTaskEstimatesEnergy => '¿Por qué mis estimaciones de tareas cambian basándose en la energía?';

  @override
  String get faqTaskEstimatesEnergyAnswer => 'La app usa tu nivel de energía para ajustar las estimaciones de tiempo porque tu productividad varía con cómo te sientes. En días de alta energía (7-10), las tareas podrían estimarse que tomen más tiempo porque puedes trabajar más minuciosamente y manejar complejidad. En días de baja energía (1-4), la misma tarea obtiene estimaciones más cortas con pasos más simples, asumiendo que necesitas trabajar más eficientemente y tomar más descansos.';

  @override
  String get faqWhatIsFlowmodoro => '¿Qué es la Técnica Flowmodoro?';

  @override
  String get faqWhatIsFlowmodoroAnswer => 'Flowmodoro es un método de productividad flexible donde trabajas hasta que naturalmente sientes ganas de tomar un descanso, luego tomas un descanso proporcional a tu tiempo de trabajo (usualmente 1/5 del tiempo de trabajo). Puedes configurar períodos de tiempo personalizados, pero la app usa los valores predeterminados de Pomodoro (sesiones de trabajo de 25 minutos, descansos de 5 minutos) como punto de partida.';

  @override
  String get faqKanbanBoards => '¿Cómo funcionan los tableros Kanban?';

  @override
  String get faqKanbanBoardsAnswer => 'Los tableros Kanban te ayudan a visualizar tu flujo de trabajo con columnas como \"Por Hacer\", \"En Progreso\" y \"Hecho\". Puedes arrastrar tareas entre columnas para registrar su estado y ver tu progreso de un vistazo.';

  @override
  String get faqTimeBlocks => '¿Qué son los Bloques de Tiempo?';

  @override
  String get faqTimeBlocksAnswer => 'El bloqueo de tiempo es un método de programación donde asignas franjas horarias específicas a diferentes actividades o tipos de trabajo. Esto te ayuda a mantenerte enfocado y asegura que las tareas importantes tengan tiempo dedicado.';

  @override
  String get faqCustomizeTimers => '¿Puedo personalizar las duraciones del temporizador?';

  @override
  String get faqCustomizeTimersAnswer => '¡Sí! Puedes ajustar los períodos de trabajo, duraciones de descanso e intervalos de descanso largo en la configuración del temporizador para coincidir con tu ritmo de productividad personal.';

  @override
  String get faqEnergyTaskScheduling => '¿Cómo afecta mi nivel de energía la programación de tareas?';

  @override
  String get faqEnergyTaskSchedulingAnswer => 'La app considera tu energía diaria al sugerir la programación de tareas. Los períodos de alta energía son mejores para tareas complejas y demandantes, mientras que los períodos de baja energía se reservan para actividades más simples y rutinarias. La IA aprende tus patrones con el tiempo para sugerir el momento óptimo para diferentes tipos de trabajo.';

  @override
  String get faqSymptomRatingsAccuracy => '¿Qué tan precisas deberían ser mis calificaciones de síntomas?';

  @override
  String get faqSymptomRatingsAccuracyAnswer => 'Usa una escala consistente (1-10) y trata de ser lo más objetivo posible. La escala 1-10 está basada en la [Escala de Dolor Mankoski](https://www.painscale.com/article/mankoski-pain-scale), que proporciona descripciones específicas para cada nivel (1 = apenas perceptible, 10 = inconsciente por el dolor). La clave es la consistencia a lo largo del tiempo en lugar de la precisión perfecta en entradas individuales.';

  @override
  String get faqCustomSymptoms => '¿Puedo registrar síntomas personalizados?';

  @override
  String get faqCustomSymptomsAnswer => '¡Sí! Puedes agregar tipos de síntomas personalizados más allá de los predeterminados. Esto te permite registrar cualquier cosa específica a tu condición de salud.';

  @override
  String get faqDataStorage => '¿Dónde se almacenan mis datos?';

  @override
  String get faqDataStorageAnswer => 'Actualmente, todos tus datos se almacenan en una base de datos en la nube. Sin embargo, el desarrollador está trabajando en implementar una solución de almacenamiento local y una forma para que los usuarios auto-alojen sus datos si lo prefieren.';

  @override
  String get faqMultipleDevices => '¿Puedo usar la app en múltiples dispositivos?';

  @override
  String get faqMultipleDevicesAnswer => '¡Sí! Como tus datos se almacenan en una base de datos en la nube, puedes acceder a ellos desde cualquier dispositivo siempre que hayas iniciado sesión en tu cuenta.';

  @override
  String get faqDeleteApp => '¿Qué pasa si elimino la app?';

  @override
  String get faqDeleteAppAnswer => 'Tus datos permanecerán almacenados de forma segura en la base de datos en la nube. Puedes reinstalar la app e iniciar sesión nuevamente en tu cuenta para acceder a todos tus datos.';

  @override
  String get faqDataMissing => 'Mis datos parecen estar perdidos';

  @override
  String get faqDataMissingAnswer => 'Verifica que tengas una conexión a internet activa. Revisa si estás viendo la fecha correcta. Si el problema persiste, intenta cerrar sesión y volver a iniciarla en tu cuenta para refrescar la sincronización de datos.';

  @override
  String get faqAppSlow => 'La app está ejecutándose lentamente';

  @override
  String get faqAppSlowAnswer => 'Intenta reiniciar la app primero. Si los problemas persisten, puedes limpiar la caché y datos de la app en la Configuración de tu teléfono > Apps > SpiceEase > Almacenamiento.';

  @override
  String get faqFeatureMissing => 'No puedo encontrar una función que usaba antes';

  @override
  String get faqFeatureMissingAnswer => 'Las funciones pueden estar ubicadas en diferentes secciones después de las actualizaciones. Revisa la sección de ayuda o usa la función de búsqueda para encontrar lo que estás buscando.';

  @override
  String get searchFAQs => 'Buscar FAQs...';

  @override
  String get noFAQsFound => 'No se encontraron FAQs';

  @override
  String get tryDifferentSearch => 'Intenta un término de búsqueda diferente';

  @override
  String get tutorialsSubtitle => 'Tutoriales paso a paso';

  @override
  String get tipsSubtitle => 'Consejos y trucos para mejor productividad';

  @override
  String get frequentlyAskedQuestionsSubtitle => 'Encuentra respuestas a preguntas comunes';

  @override
  String get troubleshootingSubtitle => 'Resuelve problemas comunes';

  @override
  String get contactSupportSubtitle => 'Obtén ayuda de nuestro equipo de soporte';

  @override
  String get sendFeedbackSubtitle => 'Comparte tus pensamientos y sugerencias';

  @override
  String get tutorialCategoryGettingStarted => 'Primeros Pasos';

  @override
  String get tutorialCategoryTasks => 'Tareas';

  @override
  String get tutorialCategoryHabits => 'Hábitos';

  @override
  String get tutorialCategoryHealth => 'Salud';

  @override
  String get tutorialCategoryTimeManagement => 'Gestión del Tiempo';

  @override
  String get tutorialCategoryReports => 'Reportes';

  @override
  String get tutorialCategorySettings => 'Configuración';

  @override
  String get tutorial2Min => '2 min';

  @override
  String get tutorial3Min => '3 min';

  @override
  String get tutorial4Min => '4 min';

  @override
  String get tutorial5Min => '5 min';

  @override
  String get tutorialBeginner => 'Principiante';

  @override
  String get tutorialIntermediate => 'Intermedio';

  @override
  String get tutorialAdvanced => 'Avanzado';

  @override
  String get tutorialUnderstandingIconGrid => 'Entendiendo la Cuadrícula de Iconos';

  @override
  String get tutorialUnderstandingListView => 'Entendiendo la Vista de Lista';

  @override
  String get tutorialCreatingFirstTask => 'Creando tu Primera Tarea';

  @override
  String get tutorialEditingDeletingTasks => 'Editando y Eliminando Tareas';

  @override
  String get tutorialWorkingWithSubtasks => 'Trabajando con Subtareas';

  @override
  String get tutorialTaskEstimationTimePlanning => 'Estimación de Tareas y Planificación de Tiempo';

  @override
  String get tutorialSettingUpDailyHabits => 'Configurando Hábitos Diarios';

  @override
  String get tutorialManagingHabitStreaks => 'Gestionando Rachas de Hábitos';

  @override
  String get tutorialTrackingHealthSymptoms => 'Rastreando Síntomas de Salud';

  @override
  String get tutorialAddingMedicationTracking => 'Añadiendo Seguimiento de Medicamentos';

  @override
  String get tutorialRecordingMoodEntries => 'Registrando Entradas de Estado de Ánimo';

  @override
  String get tutorialRecordingEnergyEntries => 'Registrando Entradas de Energía';

  @override
  String get tutorialUsingFlowmodoroTechnique => 'Usando la Técnica Flowmodoro';

  @override
  String get tutorialManagingKanbanBoard => 'Gestionando tu Tablero Kanban';

  @override
  String get tutorialSchedulingTimeBlocks => 'Programando con Bloques de Tiempo';

  @override
  String get tutorialUnderstandingReportsCharts => 'Entendiendo Reportes y Gráficos';

  @override
  String get tutorialCustomizingReportViews => 'Personalizando Vistas de Reportes';

  @override
  String get tutorialPersonalizingSettings => 'Personalizando tu Configuración';

  @override
  String get tutorialManagingAccount => 'Gestionando tu Cuenta';

  @override
  String get tutorialIconGridStep1 => 'La pantalla principal muestra una cuadrícula de iconos con diferentes categorías';

  @override
  String get tutorialIconGridStep2 => 'Cada icono representa un tipo diferente de datos que puedes rastrear';

  @override
  String get tutorialIconGridStep3 => 'Toca cualquier icono para ver tus entradas existentes para esa categoría';

  @override
  String get tutorialIconGridStep4 => 'Usa el botón \"+\" dentro de cada categoría para añadir nuevas entradas';

  @override
  String get tutorialIconGridStep5 => 'Alternativamente, para hábitos, medicamentos, tareas o síntomas, usa los botones \"Añadir [Elemento]\" para acceso rápido';

  @override
  String get tutorialIconGridStep6 => 'El diseño de cuadrícula facilita ver todas tus opciones de seguimiento';

  @override
  String get tutorialListViewStep1 => 'Toca el icono de lista en la navegación inferior para cambiar a vista de lista';

  @override
  String get tutorialListViewStep2 => 'La lista muestra todos tus elementos agrupados por tipo (tareas, hábitos, etc.)';

  @override
  String get tutorialListViewStep3 => 'Los elementos están codificados por colores por categoría para fácil identificación';

  @override
  String get tutorialListViewStep4 => 'Puedes ver el estado de finalización y fechas de vencimiento de un vistazo';

  @override
  String get tutorialListViewStep5 => 'Toca cualquier elemento para ver detalles o marcarlo como completo';

  @override
  String get tutorialListViewStep6 => 'Usa las opciones de filtro y ordenación para organizar tu vista';

  @override
  String get tutorialListViewStep7 => 'Cambia de vuelta a vista de cuadrícula en cualquier momento usando el icono de cuadrícula';

  @override
  String get tutorialFirstTaskStep1 => 'Ve a la pantalla de seguimiento';

  @override
  String get tutorialFirstTaskStep2 => 'Elige el icono de tarea de la cuadrícula de iconos O toca el botón \"Añadir Tarea\"';

  @override
  String get tutorialFirstTaskStep3 => 'Si usas la cuadrícula de iconos: toca el botón \"+\" en la esquina superior derecha';

  @override
  String get tutorialFirstTaskStep4 => 'Ingresa un título y descripción para tu tarea';

  @override
  String get tutorialFirstTaskStep5 => 'Establece una fecha de vencimiento si deseas y un nivel de prioridad';

  @override
  String get tutorialFirstTaskStep6 => 'Añade subtareas si es necesario presionando el botón \"Dividir en subtareas\"';

  @override
  String get tutorialFirstTaskStep7 => 'Toca \"Guardar\" para crear tu tarea';

  @override
  String get tutorialEditTaskStep1 => 'Navega al icono de tarea en la cuadrícula';

  @override
  String get tutorialEditTaskStep2 => 'Toca cualquier tarea existente para abrirla';

  @override
  String get tutorialEditTaskStep3 => 'Para editar: toca el botón de editar y modifica cualquier campo';

  @override
  String get tutorialEditTaskStep4 => 'Puedes cambiar título, descripción, fecha de vencimiento o prioridad';

  @override
  String get tutorialEditTaskStep5 => 'Para eliminar: toca el botón de eliminar y confirma';

  @override
  String get tutorialEditTaskStep6 => 'Guarda los cambios al editar';

  @override
  String get tutorialSubtasksStep1 => 'Al crear o editar una tarea, toca \"Dividir en subtareas\"';

  @override
  String get tutorialSubtasksStep2 => 'Esto genera automáticamente una lista de subtareas bajo la tarea principal';

  @override
  String get tutorialSubtasksStep3 => 'Cada subtarea puede marcarse como completa independientemente y tiene su propio tiempo estimado';

  @override
  String get tutorialSubtasksStep4 => 'La tarea principal muestra progreso basado en subtareas completadas';

  @override
  String get tutorialSubtasksStep5 => 'Las subtareas ayudan a dividir tareas complejas en pasos manejables';

  @override
  String get tutorialSubtasksStep6 => 'Puedes añadir, editar o eliminar subtareas en cualquier momento';

  @override
  String get tutorialSubtasksStep7 => 'La tarea principal se completa cuando todas las subtareas están hechas';

  @override
  String get tutorialEstimationStep1 => 'Al crear o editar una tarea, busca el botón \"Estimar tarea\"';

  @override
  String get tutorialEstimationStep2 => 'Tu nivel de energía actual impacta directamente la estimación de tareas';

  @override
  String get tutorialEstimationStep3 => 'Niveles de energía más altos sugieren tiempos de finalización más cortos y menos subdivisión necesaria';

  @override
  String get tutorialEstimationStep4 => 'Niveles de energía más bajos pueden requerir dividir tareas en trozos más pequeños y manejables';

  @override
  String get tutorialEstimationStep5 => 'La aplicación considera tus patrones de energía al sugerir estimaciones de tiempo';

  @override
  String get tutorialEstimationStep6 => 'Los tiempos estimados ayudan con la programación y bloques de tiempo';

  @override
  String get tutorialHabitsStep1 => 'Ve a la pantalla de seguimiento';

  @override
  String get tutorialHabitsStep2 => 'Elige el icono de hábito de la cuadrícula de iconos O toca el botón \"Añadir Hábito\"';

  @override
  String get tutorialHabitsStep3 => 'Si usas la cuadrícula de iconos: toca el botón \"+\" en la esquina superior derecha';

  @override
  String get tutorialHabitsStep4 => 'Ingresa el nombre del hábito (ej., \"Beber 8 vasos de agua\")';

  @override
  String get tutorialHabitsStep5 => 'Elige la frecuencia: diario, semanal o personalizado';

  @override
  String get tutorialHabitsStep6 => 'Para frecuencia personalizada, selecciona días específicos de la semana';

  @override
  String get tutorialHabitsStep7 => 'Establece veces objetivo por día si aplica';

  @override
  String get tutorialHabitsStep8 => 'Añade una descripción si deseas';

  @override
  String get tutorialHabitsStep9 => 'Guarda tu hábito y márcalo como completo cada día que lo hagas';

  @override
  String get tutorialStreaksStep1 => 'Ve tus hábitos en la cuadrícula o lista';

  @override
  String get tutorialStreaksStep2 => 'Cada hábito muestra si fue completado hoy';

  @override
  String get tutorialStreaksStep3 => 'Toca la casilla de verificación de un hábito para marcarlo como completo para el día';

  @override
  String get tutorialStreaksStep4 => 'Marca hábitos como completos diariamente para mantener rachas';

  @override
  String get tutorialStreaksStep5 => 'Las rachas se reinician si pierdes un día (basado en tu frecuencia)';

  @override
  String get tutorialStreaksStep6 => 'Usa la pantalla de reportes para ver tu historial de hábitos';

  @override
  String get tutorialStreaksStep7 => 'Apunta a la consistencia en lugar de la perfección';

  @override
  String get tutorialStreaksStep8 => 'Celebra rachas de hitos para mantenerte motivado';

  @override
  String get tutorialSymptomsStep1 => 'Ve a la pantalla de seguimiento';

  @override
  String get tutorialSymptomsStep2 => 'Elige el icono de síntoma de la cuadrícula de iconos O toca el botón \"Añadir Síntoma\"';

  @override
  String get tutorialSymptomsStep3 => 'Si usas la cuadrícula de iconos: toca el botón \"+\" en la esquina superior derecha';

  @override
  String get tutorialSymptomsStep4 => 'Elige de categorías comunes o añade una personalizada';

  @override
  String get tutorialSymptomsStep5 => 'Califica la severidad en una escala de 1-10 (usa escala Mankoski si prefieres)';

  @override
  String get tutorialSymptomsStep6 => 'Añade notas sobre desencadenantes, contexto o tratamientos probados';

  @override
  String get tutorialSymptomsStep7 => 'Incluye ubicación en el cuerpo si aplica';

  @override
  String get tutorialSymptomsStep8 => 'Guarda la entrada para rastrear patrones a lo largo del tiempo';

  @override
  String get tutorialMedicationStep1 => 'Ve a la pantalla de seguimiento';

  @override
  String get tutorialMedicationStep2 => 'Elige el icono de medicamento de la cuadrícula de iconos';

  @override
  String get tutorialMedicationStep3 => 'Toca el botón \"+\" en la esquina superior derecha';

  @override
  String get tutorialMedicationStep4 => 'Ingresa el nombre del medicamento y cantidad de dosis';

  @override
  String get tutorialMedicationStep5 => 'Selecciona la unidad (mg, ml, tabletas, etc.)';

  @override
  String get tutorialMedicationStep6 => 'Establece la frecuencia: diario, semanal, según sea necesario, o horario personalizado';

  @override
  String get tutorialMedicationStep7 => 'Guarda el medicamento y márcalo como tomado cuando tomes tu dosis';

  @override
  String get tutorialMoodStep1 => 'Ve a la pantalla de seguimiento';

  @override
  String get tutorialMoodStep2 => 'Elige el icono de estado de ánimo de la cuadrícula de iconos';

  @override
  String get tutorialMoodStep3 => 'Toca el botón \"+\" en la esquina superior derecha';

  @override
  String get tutorialMoodStep4 => 'Selecciona tu nivel de estado de ánimo actual en una escala de 1-10';

  @override
  String get tutorialMoodStep5 => 'Añade notas sobre qué influyó en tu estado de ánimo';

  @override
  String get tutorialMoodStep6 => 'Incluye cualquier desencadenante, evento o circunstancia relevante';

  @override
  String get tutorialMoodStep7 => 'Nota cualquier estrategia de afrontamiento utilizada';

  @override
  String get tutorialMoodStep8 => 'Guarda la entrada de estado de ánimo para rastrear patrones a lo largo del tiempo';

  @override
  String get tutorialEnergyStep1 => 'Ve a la pantalla de seguimiento';

  @override
  String get tutorialEnergyStep2 => 'Elige el icono de energía de la cuadrícula de iconos';

  @override
  String get tutorialEnergyStep3 => 'Toca el botón \"+\" en la esquina superior derecha';

  @override
  String get tutorialEnergyStep4 => 'Selecciona tu nivel de energía actual en una escala de 1-10';

  @override
  String get tutorialEnergyStep5 => 'Añade notas sobre qué influyó en tu energía';

  @override
  String get tutorialEnergyStep6 => 'Incluye cualquier desencadenante, evento o circunstancia relevante';

  @override
  String get tutorialFlowmodoroStep1 => 'Navega a la página de Gestión del Tiempo';

  @override
  String get tutorialFlowmodoroStep2 => 'Toca en \"Flowmodoro\"';

  @override
  String get tutorialFlowmodoroStep3 => 'Elige una tarea en la que trabajar de tu lista de tareas';

  @override
  String get tutorialFlowmodoroStep4 => 'Establece tu duración de trabajo (comienza con 25 minutos si no estás seguro)';

  @override
  String get tutorialFlowmodoroStep5 => 'Establece tu duración de descanso (típicamente 5-15 minutos)';

  @override
  String get tutorialFlowmodoroStep6 => 'Toca \"Iniciar\" para comenzar el temporizador de trabajo';

  @override
  String get tutorialFlowmodoroStep7 => 'Trabaja enfocado en tu tarea hasta que termine el temporizador';

  @override
  String get tutorialFlowmodoroStep8 => 'Toma el descanso cuando se te indique - aléjate del trabajo';

  @override
  String get tutorialFlowmodoroStep9 => 'Después del descanso, inicia otra sesión de trabajo o termina';

  @override
  String get tutorialFlowmodoroStep10 => 'Rastrea tus sesiones completadas para insights de productividad';

  @override
  String get tutorialKanbanStep1 => 'Ve a Gestión del Tiempo y selecciona \"Kanban\"';

  @override
  String get tutorialKanbanStep2 => 'Tus tareas están organizadas en columnas: Por Hacer, En Progreso, Hecho';

  @override
  String get tutorialKanbanStep3 => 'Arrastra tareas entre columnas para actualizar su estado';

  @override
  String get tutorialKanbanStep4 => 'Añade nuevas tareas directamente a la columna Por Hacer';

  @override
  String get tutorialKanbanStep5 => 'Mueve tareas a En Progreso cuando comiences a trabajar en ellas';

  @override
  String get tutorialKanbanStep6 => 'Completa tareas moviéndolas a Hecho';

  @override
  String get tutorialKanbanStep7 => 'Usa filtros para mostrar solo categorías específicas o prioridades';

  @override
  String get tutorialKanbanStep8 => 'Personaliza columnas y flujo de trabajo para que coincida con tus necesidades';

  @override
  String get tutorialTimeBlocksStep1 => 'Navega a Gestión del Tiempo y toca \"Bloques de Tiempo\"';

  @override
  String get tutorialTimeBlocksStep2 => 'Ve tu calendario con elementos programados existentes';

  @override
  String get tutorialTimeBlocksStep3 => 'Para programar una tarea: establece una hora de inicio y una hora de fin, o establece solo una hora de inicio si la tarea tiene una estimación de tiempo';

  @override
  String get tutorialTimeBlocksStep4 => 'Para desprogramar: presiona el botón x en la parte superior del elemento programado';

  @override
  String get tutorialTimeBlocksStep5 => 'La codificación de colores ayuda a distinguir las prioridades de las tareas';

  @override
  String get tutorialReportsStep1 => 'Navega a la sección de Reportes';

  @override
  String get tutorialReportsStep2 => 'Elige tu rango de tiempo: día, semana, mes o año';

  @override
  String get tutorialReportsStep3 => 'Si hay datos que no quieres ver, haz clic en ellos en la leyenda para ocultarlos';

  @override
  String get tutorialReportsStep4 => 'Los gráficos se actualizan automáticamente basado en tus selecciones';

  @override
  String get tutorialReportsStep5 => 'Pasa el cursor o toca puntos de datos para información detallada';

  @override
  String get tutorialReportsStep6 => 'Usa gráficos para identificar patrones y tendencias en tus datos';

  @override
  String get tutorialCustomReportsStep1 => 'En la sección de Reportes, busca la leyenda debajo de los gráficos';

  @override
  String get tutorialCustomReportsStep2 => 'Toca cualquier elemento en la leyenda para ocultar/mostrar esa serie de datos';

  @override
  String get tutorialCustomReportsStep3 => 'Los elementos ocultos aparecen en gris en la leyenda';

  @override
  String get tutorialCustomReportsStep4 => 'Esto te permite enfocarte en puntos de datos específicos';

  @override
  String get tutorialCustomReportsStep5 => 'Por ejemplo, oculta los hábitos para ver otros elementos más claramente';

  @override
  String get tutorialCustomReportsStep6 => 'Combina con filtros de fecha para análisis preciso';

  @override
  String get tutorialSettingsStep1 => 'Navega a Configuración desde el menú principal';

  @override
  String get tutorialSettingsStep2 => 'Personaliza tu tema (claro, oscuro o sistema)';

  @override
  String get tutorialSettingsStep3 => 'Establece tu idioma y región preferidos';

  @override
  String get tutorialAccountStep1 => 'Ve a Configuración y toca \"Cuenta\"';

  @override
  String get tutorialAccountStep2 => 'Ve los detalles de tu cuenta y dirección de correo electrónico';

  @override
  String get tutorialAccountStep3 => 'Cambia tu contraseña o correo electrónico si es necesario';

  @override
  String get account => 'Cuenta';

  @override
  String get accountSettings => 'Configuración de Cuenta';

  @override
  String get manageAccountInfo => 'Gestiona la información de tu cuenta';

  @override
  String get accountInformation => 'Información de la Cuenta';

  @override
  String get accountActions => 'Acciones de la Cuenta';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get changeEmail => 'Cambiar Correo Electrónico';

  @override
  String get newEmail => 'Nuevo Correo Electrónico';

  @override
  String get signOutFromAccount => 'Cerrar sesión de tu cuenta';

  @override
  String get signOutConfirmation => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get notSignedIn => 'No has iniciado sesión';

  @override
  String get pleaseEnterEmail => 'Por favor ingresa un correo electrónico';

  @override
  String get pleaseEnterValidEmail => 'Por favor ingresa un correo electrónico válido';

  @override
  String get pleaseEnterPassword => 'Por favor ingresa tu contraseña';

  @override
  String get pleaseEnterCurrentPassword => 'Por favor ingresa tu contraseña actual';

  @override
  String get pleaseEnterNewPassword => 'Por favor ingresa una nueva contraseña';

  @override
  String get pleaseConfirmPassword => 'Por favor confirma tu contraseña';

  @override
  String get passwordTooShort => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get emailUpdatedSuccessfully => 'Correo electrónico actualizado exitosamente';

  @override
  String get passwordUpdatedSuccessfully => 'Contraseña actualizada exitosamente';

  @override
  String get signedOutSuccessfully => 'Sesión cerrada exitosamente';

  @override
  String get weakPassword => 'La contraseña es muy débil';

  @override
  String get incorrectPassword => 'La contraseña actual es incorrecta';

  @override
  String get requiresRecentLogin => 'Por favor inicia sesión nuevamente para continuar';

  @override
  String get tooManyAttempts => 'Demasiados intentos fallidos. Por favor intenta más tarde';

  @override
  String get userDisabled => 'Esta cuenta ha sido deshabilitada';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String get securityVerificationRequired => 'Por seguridad, por favor verifica tu contraseña actual para cambiar tu dirección de correo electrónico.';

  @override
  String get passwordChangeVerification => 'Por seguridad, por favor verifica tu contraseña actual antes de establecer una nueva.';

  @override
  String get passwordRequiredForEmailChange => 'Tu contraseña es requerida para verificar este cambio de seguridad';

  @override
  String get passwordRequirements => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get emailMustBeDifferent => 'El nuevo correo electrónico debe ser diferente del actual';

  @override
  String get passwordMustBeDifferent => 'La nueva contraseña debe ser diferente de la actual';

  @override
  String get updatingEmail => 'Actualizando dirección de correo electrónico...';

  @override
  String get updatingPassword => 'Actualizando contraseña...';

  @override
  String get verifyNewEmail => 'Verificar Nuevo Correo Electrónico';

  @override
  String get emailVerificationSent => 'Se ha enviado un correo de verificación a tu nueva dirección de correo electrónico:';

  @override
  String get emailVerificationInstructions => 'Por favor revisa tu bandeja de entrada y haz clic en el enlace de verificación para completar el cambio de correo electrónico. Tu dirección de correo electrónico no se actualizará hasta que sea verificada.';

  @override
  String get resendVerification => 'Reenviar';

  @override
  String get understood => 'Entendido';

  @override
  String get verificationEmailResent => 'Correo de verificación enviado nuevamente';

  @override
  String get failedToResendVerification => 'Falló al reenviar el correo de verificación';

  @override
  String get failedToLoadUser => 'Falló al cargar información del usuario';

  @override
  String get retry => 'Reintentar';

  @override
  String get verifyingCredentials => 'Verifying credentials...';

  @override
  String get emailChangeRequiresVerification => 'Se requiere verificación de correo electrónico';

  @override
  String get emailChangeVerificationMessage => 'Para cambiar su dirección de correo electrónico, primero debe verificar su correo electrónico actual. Esto es un requisito de seguridad';

  @override
  String get currentEmail => 'Correo electrónico actual:';

  @override
  String get emailVerificationInstructions2 => 'Enviaremos un correo electrónico de verificación a tu dirección actual. Por favor, verifícalo y luego intenta cambiar tu email de nuevo';

  @override
  String get verificationEmailSent2 => 'Correo electrónico de verificación enviado a tu dirección actual';

  @override
  String get failedToSendVerification => 'Falló el envío del email de verificación';

  @override
  String get sendVerification => 'Enviar verificación';

  @override
  String get emailVerificationRequired => 'Se requiere verificación de correo electrónico antes de cambiar la dirección de correo electrónico';

  @override
  String get operationNotAllowed => 'Esta operación no está permitida';
}
