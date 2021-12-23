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

  virtual uint64_t apply() = 0;
  virtual std::ostream &print(std::ostream &out, std::string indent) = 0;
};

struct Literal : public Packet {
  const uint64_t value;

  explicit Literal(unsigned char version, const Bits &bits, size_t &offset)
      : Packet{version, 4}, value{readValue(bits, offset)} {}
  virtual ~Literal() = default;

  std::ostream &print(std::ostream &out, std::string indent) override {
    out << indent << "{ version: " << static_cast<size_t>(version)
        << ", typeId: " << static_cast<size_t>(typeId) << ", value: " << value
        << " }" << std::endl;
    return out;
  }

  uint64_t apply() override { return value; }

private:
  static uint64_t readValue(const Bits &bits, size_t &offset) {
    uint64_t value = 0;
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

struct Operator : public Packet {
  const std::vector<std::unique_ptr<Packet>> subPackets;

  explicit Operator(unsigned char version, unsigned char typeId,
                    const Bits &bits, size_t &offset, bool fixed)
      : Packet{version, typeId}, subPackets{fixed ? readFixed(bits, offset)
                                                  : readArray(bits, offset)} {}

  virtual ~Operator() = default;
  uint64_t apply() override {
    switch (typeId) {
    case 0:
      return sum();
    case 1:
      return product();
    case 2:
      return min();
    case 3:
      return max();
    case 5:
      return greater();
    case 6:
      return less();
    case 7:
      return equal();
    }
    std::exit(-1);
  }

  std::ostream &print(std::ostream &out, std::string indent) override {
    out << indent << "{ version: " << static_cast<size_t>(version)
        << ", typeId: " << static_cast<size_t>(typeId) << std::endl;
    for (size_t i = 0; i < subPackets.size(); i++) {
      subPackets[i]->print(out, indent + " ");
    }
    out << indent << "}" << std::endl;
    return out;
  }

private:
  static std::vector<std::unique_ptr<Packet>> readFixed(const Bits &bits,
                                                        size_t &offset) {
    std::vector<std::unique_ptr<Packet>> subPackets;
    auto length = read<size_t, 15>(bits, offset);
    auto end = offset + length;
    while (offset < end) {
      subPackets.push_back(Packet::parse(bits, offset));
    }
    return subPackets;
  }

  static std::vector<std::unique_ptr<Packet>> readArray(const Bits &bits,
                                                        size_t &offset) {
    auto length = read<size_t, 11>(bits, offset);
    std::vector<std::unique_ptr<Packet>> subPackets;
    for (size_t i = 0; i < length; i++) {
      subPackets.push_back(Packet::parse(bits, offset));
    }
    return subPackets;
  }

  uint64_t sum() {
    uint64_t value = 0;
    for (size_t i = 0; i < subPackets.size(); i++) {
      value += subPackets[i]->apply();
    }
    return value;
  }

  uint64_t product() {
    uint64_t value = 1;
    for (size_t i = 0; i < subPackets.size(); i++) {
      value *= subPackets[i]->apply();
    }
    return value;
  }

  uint64_t min() {
    uint64_t value = -1;
    for (size_t i = 0; i < subPackets.size(); i++) {
      value = std::min(subPackets[i]->apply(), value);
    }
    return value;
  }

  uint64_t max() {
    uint64_t value = 0;
    for (size_t i = 0; i < subPackets.size(); i++) {
      value = std::max(subPackets[i]->apply(), value);
    }
    return value;
  }

  uint64_t greater() { return subPackets[0]->apply() > subPackets[1]->apply(); }

  uint64_t less() { return subPackets[0]->apply() < subPackets[1]->apply(); }

  uint64_t equal() { return subPackets[0]->apply() == subPackets[1]->apply(); }
};

std::unique_ptr<Packet> Packet::parse(const Bits &bits, size_t &offset) {
  auto version = read<unsigned char, 3>(bits, offset);
  auto typeId = read<unsigned char, 3>(bits, offset);

  if (typeId == 4) {
    return std::make_unique<Literal>(version, bits, offset);
  } else {
    if (read<bool, 1>(bits, offset)) {
      return std::make_unique<Operator>(version, typeId, bits, offset, false);
    } else {
      return std::make_unique<Operator>(version, typeId, bits, offset, true);
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

  std::cout << Packet::parse(bits, offset)->apply() << std::endl;
}
