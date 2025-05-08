import 'package:dio/dio.dart';
import 'package:mobile/entity/model/response_structure_model.dart';
import 'package:mobile/util/dio_client.dart';
import 'package:mobile/util/error_type.dart';
import 'package:mobile/util/help_util.dart';


class HomeService {
  Future<ResponseStructure<Map<String, dynamic>>> homeServiceList() async {
    try {
      final response = await DioClient.dio.get(
        "",
      );
      return ResponseStructure<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        dataFromJson: (json) => json,
      );
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        printError(
          errorMessage: ErrorType.requestError,
          statusCode: dioError.response!.statusCode,
        );
        throw Exception(ErrorType.requestError);
      } else {
        printError(
          errorMessage: ErrorType.networkError,
          statusCode: null,
        );
        throw Exception(ErrorType.networkError);
      }
    } catch (e) {
      printError(errorMessage: 'Something went wrong.', statusCode: 500);
      throw Exception(ErrorType.unexpectedError);
    }
  }
}
