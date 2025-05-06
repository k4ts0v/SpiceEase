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
  String estimatedTime(Object time, Object unit) {
    return 'Tiempo estimado: $time $unit';
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
}
