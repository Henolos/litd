#include "campaign_lock.hpp"
#include <iostream>
int main(int argc, char** argv) {
    if (argc != 3) return 2;
    CampaignLock lock;
    if (!lock.acquire(std::filesystem::u8path(argv[1]))) return 23;
    if (lock.acquire(std::filesystem::u8path(argv[1]))) return 3;
    std::cout << "ACQUIRED" << std::endl;
    if (std::string(argv[2]) == "hold") std::cin.get();
    return 0;
}
