#include <iostream>
#include <iomanip>

int main() {
	float a = 0.0;
	for (int i = 0; i < 1000; i++)
		a += 0.1;
	std::cout << std::setprecision(16) << a << std::endl;
	float b = 1e30 + 1e0 - 1e30;
	std::cout << std::setprecision(16) << b << std::endl;
	return 0;
}
