import 'dart:io';
import 'dart:convert';

void main() async {
  final queries = ['salad', 'chicken', 'salmon', 'potato', 'beef', 'vegan', 'seafood', 'vegetarian'];
  for (var q in queries) {
    var req = await HttpClient().getUrl(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=\$q'));
    var res = await req.close();
    var str = await res.transform(utf8.decoder).join();
    var data = json.decode(str);
    if (data['meals'] != null) {
      print('--- \$q ---');
      for (var meal in data['meals']) {
        print('\${meal["strMeal"]}: \${meal["strMealThumb"]}');
      }
    }
  }
}
