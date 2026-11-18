/// Порог ширины: desktop (macOS / широкий экран) vs mobile.
abstract final class AssistantBreakpoints {
  static const double desktop = 900;

  static bool isDesktop(double width) => width >= desktop;
}
