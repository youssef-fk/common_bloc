import 'package:bloc_test/bloc_test.dart';
import 'package:common_bloc/common_bloc.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('Request bloc', () {
    test('initial request state', () {
      expect(RequestBloc().state, isA<UninitializedRequestState>());
    });

    blocTest('make a simple task',
        act: (bloc) => bloc.perform(
            () async => Future.delayed(Duration(seconds: 3), () => true),
            'TimerTask'),
        build: () => RequestBloc(),
        expect: [isA<LoadingRequestState>(), isA<LoadedRequestState>()]);

    blocTest('make a simple request on internet',
        act: (bloc) => bloc.perform(
            () async => await (Dio()..interceptors.add(logginInterceptor))
                .get('https://jsonplaceholder.cypress.io/posts/1')
              ..data,
            'NetworkRequest'),
        build: () => RequestBloc(),
        expect: [isA<LoadingRequestState>(), isA<LoadedRequestState>()],
        skip: 0);
  });

  group('Request bloc errors', () {
    blocTest('simple task fail',
        act: (bloc) => bloc.perform(
            () async => Future.delayed(
                Duration(seconds: 3), () => throw Exception('failed')),
            'FailTask'),
        build: () => RequestBloc(),
        expect: [isA<LoadingRequestState>(), isA<ErrorRequestState>()],
        skip: 0);
  });
}

InterceptorsWrapper get logginInterceptor =>
    InterceptorsWrapper(onRequest: (request) {
      return request;
    }, onResponse: (response) {
      return response;
    });
