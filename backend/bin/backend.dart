import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

final List<Map<String, dynamic>> locations = [];
final List<Map<String, dynamic>> layers = [];
final List<Map<String, dynamic>> boundaries = [];

Response jsonResponse(Object data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(data),
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  );
}

final router = Router()
  ..get('/api/health', (Request request) {
    return jsonResponse({
      'success': true,
      'application': 'GIS Mapping',
      'version': '1.0.0',
      'status': 'running',
    });
  })
  ..get('/api/locations', (Request request) {
    return jsonResponse({
      'success': true,
      'count': locations.length,
      'data': locations,
    });
  })
  ..post('/api/locations', (Request request) async {
    final body = jsonDecode(await request.readAsString());

    final location = {
      'id': uuid.v4(),
      'name': body['name'] ?? 'Unnamed Location',
      'latitude': body['latitude'],
      'longitude': body['longitude'],
      'description': body['description'] ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    };

    locations.add(location);

    return jsonResponse({
      'success': true,
      'data': location,
    }, status: 201);
  })
  ..get('/api/layers', (Request request) {
    return jsonResponse({
      'success': true,
      'count': layers.length,
      'data': layers,
    });
  })
  ..post('/api/layers', (Request request) async {
    final body = jsonDecode(await request.readAsString());

    final layer = {
      'id': uuid.v4(),
      'name': body['name'] ?? 'Unnamed Layer',
      'type': body['type'] ?? 'geojson',
      'visible': body['visible'] ?? true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    layers.add(layer);

    return jsonResponse({
      'success': true,
      'data': layer,
    }, status: 201);
  })
  ..get('/api/boundaries', (Request request) {
    return jsonResponse({
      'success': true,
      'count': boundaries.length,
      'data': boundaries,
    });
  })
  ..post('/api/boundaries', (Request request) async {
    final body = jsonDecode(await request.readAsString());

    final boundary = {
      'id': uuid.v4(),
      'name': body['name'] ?? 'Unnamed Boundary',
      'geojson': body['geojson'],
      'createdAt': DateTime.now().toIso8601String(),
    };

    boundaries.add(boundary);

    return jsonResponse({
      'success': true,
      'data': boundary,
    }, status: 201);
  });

Future<void> main() async {
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(
    handler,
    '0.0.0.0',
    8080,
  );

  print('======================================');
  print('GIS Mapping Backend');
  print('======================================');
  print('Server: http://${server.address.host}:${server.port}');
  print('Health: http://${server.address.host}:${server.port}/api/health');
  print('======================================');
}
