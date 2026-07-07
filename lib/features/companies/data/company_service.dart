import 'package:dio/dio.dart';
import 'package:apiland/core/network/dio_client.dart';
import 'package:apiland/features/companies/data/company.dart';

class CompanyService {
  CompanyService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/api/companies';

  /// GET /api/companies → lista de compañías.
  Future<List<Company>> getCompanies() async {
    final res = await _dio.get(_path);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => Company.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/companies → crea una compañía y devuelve la creada.
  Future<Company> createCompany(Company company) async {
    final res = await _dio.post(_path, data: company.toJson());
    final data = res.data;
    if (data is Map<String, dynamic>) return Company.fromJson(data);
    // Si el backend no devuelve cuerpo, regresamos la que enviamos.
    return company;
  }
}
