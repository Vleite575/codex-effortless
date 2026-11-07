import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "src"))
from router import choose


class RouterTest(unittest.TestCase):
    def test_short_prompt_is_low(self):
        self.assertEqual(choose("corrija o typo neste texto")[0], "low")


    def test_code_change_is_medium(self):
        self.assertEqual(choose("implementar endpoint e criar testes")[0], "medium")


    def test_security_is_high(self):
        self.assertEqual(choose("faça uma revisão de segurança da arquitetura")[0], "high")


if __name__ == "__main__":
    unittest.main()
