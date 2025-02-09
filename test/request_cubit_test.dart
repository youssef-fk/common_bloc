import 'package:bloc_test/bloc_test.dart';
import 'package:common_bloc/src/cubit/request/request_cubit.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Request cubit',
    () {
      test(
        'initial request state',
        () {
          expect(RequestCubit().state, isA<UninitializedRequestState>());
        },
      );

      blocTest<RequestCubit, RequestState>(
        'make a simple task',
        act: (cubit) => cubit.perform(
            () async =>
                Future<dynamic>.delayed(const Duration(seconds: 3), () => true),
            'TimerTask'),
        build: () => RequestCubit(),
        expect: () => [isA<LoadingRequestState>(), isA<LoadedRequestState>()],
      );

      blocTest<RequestCubit, RequestState>(
        'make a simple request on internet',
        act: (cubit) => cubit.perform(
          () async => await (Dio()..interceptors.add(logginInterceptor))
              .get<Map<String, dynamic>>(
                  'https://jsonplaceholder.typicode.com/posts/1')
            ..data,
          'NetworkRequest',
        ),
        build: () => RequestCubit(),
        expect: () => [isA<LoadingRequestState>(), isA<LoadedRequestState>()],
        skip: 0,
      );
    },
  );

  group(
    'Request cubit errors',
    () {
      blocTest<RequestCubit, RequestState>(
        'simple task fail',
        act: (cubit) => cubit.perform(
          () async => Future<dynamic>.delayed(
            const Duration(seconds: 3),
            () => throw Exception('failed'),
          ),
          'FailTask',
        ),
        build: () => RequestCubit(),
        expect: () => [isA<LoadingRequestState>(), isA<ErrorRequestState>()],
        skip: 0,
      );
    },
  );
}

InterceptorsWrapper get logginInterceptor => InterceptorsWrapper(
      onResponse: (response, handler) => handler.next(response),
      onRequest: (options, handler) => handler.next(options),
    );
