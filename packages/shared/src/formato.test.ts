import { describe, expect, it } from 'vitest';
import { formatarPesoKg } from './formato';

describe('formatarPesoKg', () => {
  it('usa uma casa decimal e vírgula', () => {
    expect(formatarPesoKg(412.34)).toBe('412,3 kg');
    expect(formatarPesoKg(520)).toBe('520,0 kg');
  });

  it('recusa valores que não são números válidos', () => {
    expect(() => formatarPesoKg(Number.NaN)).toThrow(RangeError);
  });
});
