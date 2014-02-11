#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include <sstream>
#include <cmath>
using namespace std;

typedef unordered_map<int, vector<double> > waveMap;
const int dict_length = 24;
const int target_length = 3;
const int start_wave = 390;
const int end_wave = 780;



void printVector(vector<double> &v) {
  for (int i = 0; i < v.size(); i++)
    cout << v[i] << " ";
  cout << endl;
  return;
}
void viewHashmap(waveMap &map) {
  for (waveMap::iterator it = map.begin(); it != map.end(); it++) {
    cout << it->first << ": ";
    printVector(it->second);
  }
  return;
}

waveMap readInput(string &filename, int vector_length) {
  ifstream file1;
  file1.open(filename);
  string line;
  waveMap result;

  while (!file1.eof()) {
    getline(file1, line);
    
    istringstream iss(line);
    int wave;
    vector<double> v(vector_length, 0.0);
    iss >> wave;
    for (int i = 0; i < vector_length; i++)
      iss >> v[i];
    result.insert(make_pair(wave, v));


  }
  file1.close();

  return result;

}

void checkRange(double &x) {
  if (x < 0)
    x = 0.0;
  else if (x > 255)
    x = 255.0;
 
  return;
}

void calculateXYZ(waveMap &dict, waveMap &target, int idx, double &r, double &g, double &b) {
  double sumx = 0;
  double sumy = 0;
  double sumz = 0;
  
  for (int wave = start_wave; wave <= end_wave; wave = wave + 5) {
    sumx += dict[wave][idx] * target[wave][0];
    sumy += dict[wave][idx] * target[wave][1];
    sumz += dict[wave][idx] * target[wave][2];
  }

  double sum = sumx + sumy + sumz;

  //sumx = sumx / sum;
  //sumy = sumy / sum;
  //sumz = sumz / sum;
  
  r = 3.2479 * sumx - 1.5427 * sumy - 0.5019 * sumz;
  g = -0.9733 * sumx + 1.8788 * sumy + 0.0430 * sumz;
  b = 0.057 * sumx - 0.2045 * sumy + 1.0573 * sumz;

  //cout << "(" << r << ", " << g << ", " << b << ")" << endl; 

  checkRange(r);
  checkRange(g);
  checkRange(b);
  
  r = pow(r, 1.0/2.2);
  g = pow(g, 1.0/2.2);
  b = pow(b, 1.0/2.2);
  
  return;
}


int main() {

  string filename1("target.txt");
  string filename2("dict.txt");
  waveMap target = readInput(filename1, target_length);
  waveMap dict = readInput(filename2, dict_length);

  //viewHashmap(target);
  //viewHashmap(dict);

  vector<vector<double> > potentialRGB;
  double maxP = 0.0;
  double ratio = 1.0;

  for (int i = 0; i < dict_length; i++) {
    double r, g, b;
    calculateXYZ(dict, target, i, r, g, b);
    vector<double> elem(3, 0.0);
    elem[0] = r;
    elem[1] = g;
    elem[2] = b;


    if (r > maxP) {
      maxP = r;
      ratio = 255.0 / r;
    }
    if (g > maxP) {
      maxP = g;
      ratio = 255.0 / g;
    }
    if (b > maxP) {
      maxP = b;
      ratio = 255.0 / b;
    }


    potentialRGB.push_back(elem);
  }


  //cout << "max RGB: " << maxP << endl;
  //cout << "ratio: " << ratio << endl;

  

  for (int i = 0; i < potentialRGB.size(); i++) {
    potentialRGB[i][0] *= ratio;
    potentialRGB[i][1] *= ratio;
    potentialRGB[i][2] *= ratio;
  
    cout << "color #" << i+1 << " : (" 
	 << (int)round(potentialRGB[i][0]) << ", " 
	 << (int)round(potentialRGB[i][1]) << ", "
	 << (int)round(potentialRGB[i][2]) 
	 << ")" << endl;
  }
  
  
  return 0;
}
