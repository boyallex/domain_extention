abstract interface class IUsecase<Input, Output> {
  Output call(Input input);
}
