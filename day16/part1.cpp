#include <fstream>
#include <iostream>
#include <vector>

// Ugh.. vector<bool> :(
typedef std::vector<bool> Bits;

unsigned char to_nibble(char c) {
  if (c <= '9') {
    return c - '0';
  } else {
    return c + 10 - 'A';
  }
}

Bits to_bits(std::string hexa) {
  Bits bits;
  for (auto c : hexa) {
    auto nibble = to_nibble(c);
    bits.push_back(nibble & 8);
    bits.push_back(nibble & 4);
    bits.push_back(nibble & 2);
    bits.push_back(nibble & 1);
  }
  return bits;
}

template <typename T, size_t C> T read(const Bits &bits, size_t &offset) {
  T value = 0;
  for (size_t i = 0; i < C; i++) {
    value <<= 1;
    value |= bits[offset + i];
  }
  offset += C;
  return value;
}

struct Packet {
  const unsigned char version;
  const unsigned char typeId;

  explicit Packet(unsigned char version, unsigned char typeId)
      : version{version}, typeId{typeId} {}
  virtual ~Packet() = default;

  static std::unique_ptr<Packet> parse(const Bits &bits, size_t &offet);

  virtual uint64_t sumVersions() { return version; }
};

struct Literal : public Packet {
  const uint64_t value;

  explicit Literal(unsigned char version, const Bits &bits, size_t &offset)
      : Packet{version, 4}, value{readValue(bits, offset)} {}
  virtual ~Literal() = default;

private:
  static uint64_t readValue(const Bits &bits, size_t &offset) {
    auto value = 0;
    while (offset < bits.size()) {
      unsigned char v = read<unsigned char, 5>(bits, offset);
      value <<= 4;
      value |= v & 15;
      if ((v & 16) == 0) {
        break;
      }
    }
    return value;
  }
};

struct FixedOperator : public Packet {
  const std::vector<std::unique_ptr<Packet>> subPackets;

  explicit FixedOperator(unsigned char version, unsigned char typeId,
                         const Bits &bits, size_t &offset)
      : Packet{version, typeId}, subPackets{readValue(bits, offset)} {}

  virtual ~FixedOperator() = default;

  uint64_t sumVersions() override {
    uint64_t version = this->version;
    for (size_t i = 0; i < subPackets.size(); i++) {
      version += subPackets[i]->sumVersions();
    }
    return version;
  }

private:
  static std::vector<std::unique_ptr<Packet>> readValue(const Bits &bits,
                                                        size_t &offset) {
    std::vector<std::unique_ptr<Packet>> subPackets;
    auto length = read<size_t, 15>(bits, offset);
    auto end = offset + length;
    while (offset < end) {
      subPackets.push_back(Packet::parse(bits, offset));
    }
    return subPackets;
  }
};

struct ArrayOperator : public Packet {
  const std::vector<std::unique_ptr<Packet>> subPackets;

  explicit ArrayOperator(unsigned char version, unsigned char typeId,
                         const Bits &bits, size_t &offset)
      : Packet{version, typeId}, subPackets{readValue(bits, offset)} {}

  virtual ~ArrayOperator() = default;

  uint64_t sumVersions() override {
    uint64_t version = this->version;
    for (size_t i = 0; i < subPackets.size(); i++) {
      version += subPackets[i]->sumVersions();
    }
    return version;
  }

private:
  static std::vector<std::unique_ptr<Packet>> readValue(const Bits &bits,
                                                        size_t &offset) {
    auto length = read<size_t, 11>(bits, offset);
    std::vector<std::unique_ptr<Packet>> subPackets;
    for (size_t i = 0; i < length; i++) {
      subPackets.push_back(Packet::parse(bits, offset));
    }
    return subPackets;
  }
};

std::unique_ptr<Packet> Packet::parse(const Bits &bits, size_t &offset) {
  auto version = read<unsigned char, 3>(bits, offset);
  auto typeId = read<unsigned char, 3>(bits, offset);

  if (typeId == 4) {
    return std::make_unique<Literal>(version, bits, offset);
  } else {
    if (read<bool, 1>(bits, offset)) {
      return std::make_unique<ArrayOperator>(version, typeId, bits, offset);
    } else {
      return std::make_unique<FixedOperator>(version, typeId, bits, offset);
    }
  }
}

std::string load() {
  std::string buffer;
  std::ifstream stream("input.txt");
  stream >> buffer;
  return buffer;
}

int main() {
  auto bits = to_bits(load());
  size_t offset = 0;

  std::cout << Packet::parse(bits, offset)->sumVersions() << std::endl;
}
