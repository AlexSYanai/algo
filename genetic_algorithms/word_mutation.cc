#include <string>
#include <random>
#include <iostream>

std::random_device g_rd;
std::mt19937 g_mers(g_rd());

float randNum(float starting, float ending) {
  std::uniform_real_distribution<float> dist(starting, ending);
  return dist(g_mers);
}

namespace Selection {
  const std::string all_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz";
  const int all_chars_len     = all_chars.length();

  std::string randomString(int len) {
    std::string new_string = "";

    for (int i = 0; i < len; ++i) {
      new_string += all_chars.at(floor(randNum(0.0,all_chars_len)));
    }

    return new_string;
  }

  float getFitness(std::string target_str, std::string candidate_str, int g_pop_size)
 { 
    int target_len = target_str.length();
    float distance = 0.0;

    for (int i = 0; i < target_len; ++i) {
      distance += std::abs((int) target_str[i] - (int) candidate_str[i]);
    }

    return exp(distance / -10) * 100;
  }
  
  std::string mutate(std::string current_gen, float rate, int g_pop_size, std::string target) {
    float new_fitness;
    std::string next_gen  = current_gen;
    int target_len        = current_gen.length();
    float best_fitness    = 0;
    float current_fitness = getFitness(target, current_gen, g_pop_size);

    for (int i = 0; i < g_pop_size; ++i) {
      std::string temp = "";

      for (int j = 0; j < target_len; ++j) {
        if (randNum(0.0,1.0) <= rate) {
          temp += all_chars[floor(randNum(0.0,all_chars_len))];
        } else {
          temp += current_gen[j];
        }
      }

      new_fitness = getFitness(target, temp, g_pop_size);
      if (new_fitness > current_fitness) {
        next_gen = temp;
        current_fitness = new_fitness;
      }
    }

    return next_gen;
  }
}

class WordMutation {
  private:
    int gen_count = 1;
    int pop_size;
    float current_rate;
    std::string first_gen;
    std::string target_str;

    void mutationRate(std::string target_str, std::string candidate_str) {
      float w = Selection::getFitness(target_str,candidate_str, pop_size);
      current_rate = (1.0 - exp(-(100.0 - w) / 400.0)); 
    }

    void logGen() {
      float w = Selection::getFitness(target_str,first_gen, pop_size);
      std::cout << first_gen << " -- Gen: " << gen_count << ", Fitness: " << w << std::endl;
    }
  public:
    WordMutation(int n=100, std::string target="ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz") {
      pop_size   = n;
      target_str = target;
      first_gen  = Selection::randomString(target_str.length());
    }

    void runMutation() {
      while (first_gen != target_str) {
        mutationRate(target_str,first_gen);
        first_gen = Selection::mutate(first_gen, current_rate, pop_size, target_str);

        logGen();
        gen_count++;
      }
    }
};

int main() {
  std::string target_str = "This is a test phrase";
  WordMutation wm(100,target_str);
  wm.runMutation();

  return 0;
}
